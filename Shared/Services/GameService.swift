//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Combine
import Foundation
import SwiftUI
import CombineMoya

protocol GameService {
    func loadGames()
    func load(game: LoadableSubject<Game>, gameId: String)

    func create(game: LoadableSubject<Game>, initialBet: Int, color: Color, bombs: Int)
    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int)
    func cashOut(game: LoadableSubject<Game>, gameId: String)
    func delete(gameId: String)
}

struct GamesResponse: Decodable {
    var games: [GameResponse]
}

protocol BaseGameResponse: Decodable {
    var id: String { get }
    var tiles: [String] { get }
    var stake: Int { get }
    var next: Int? { get }
    var multiplier: Double { get }
    var state: State { get }
    var secret: String { get }
    var colorId: Int { get }
    var plain: String? { get }
    var initialBet: Int { get }
    var bombs: Int { get }
}

enum State: String, Codable {
    case inGame = "IN_GAME"
    case hitBomb = "HIT_BOMB"
    case cashedOut = "CASHED_OUT"
}

struct GameProfileResponse: BaseGameResponse {
    var id: String
    var tiles: [String]
    var stake: Int
    var next: Int?
    var multiplier: Double
    var state: State
    var secret: String
    var colorId: Int
    var plain: String?
    var initialBet: Int
    var bombs: Int

    var profile: Profile?
}

struct GameResponse: BaseGameResponse {
    var id: String
    var tiles: [String]
    var stake: Int
    var next: Int?
    var multiplier: Double
    var state: State
    var secret: String
    var colorId: Int
    var plain: String?
    var initialBet: Int
    var bombs: Int

    static func toDomain(response: BaseGameResponse) -> Game {
        let orderedTiles = response.tiles.compactMap(Tile.from(string:))

        let tiles = orderedTiles.reduce(into: [Int: Tile]()) {
            $0[$1.tileId] = $1.tile
        }

        return Game(id: response.id,
                tiles: tiles,
                secret: response.secret,
                stake: response.stake,
                next: response.next,
                multiplier: response.multiplier,
                color: Game.colors[response.colorId],
                isActive: response.state == .inGame,
                isCashedOut: response.state == .cashedOut,
                initialBet: response.initialBet,
                bombs: response.bombs,
                plain: response.plain,
                lastTile: orderedTiles.last?.tile
        )
    }
}

extension GameProfileResponse {
    static func toDomain(response: Self) -> (game: Game, profile: Profile?) {
        let game = GameResponse.toDomain(response: response)

        return (game: game, profile: response.profile)
    }
}

struct RemoteGameService: GameService {
    let appState: Store<AppState>
    let provider: APIProvider
    let globalCancelBag = CancelBag()

    func loadGames() {
        let cancelBag = CancelBag()
        appState[\.userData.games].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        provider
                .requestPublisher(.games)
                .map(GamesResponse.self)
                .map(\.games)
                .map { games in
                    games.map(GameResponse.toDomain)
                }
                .sinkToLoadable {
                    weakAppState?[\.userData.games] = $0
                }
                .store(in: cancelBag)
    }

    func load(game: LoadableSubject<Game>, gameId: String) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        provider
                .requestPublisher(.game(id: gameId))
                .map(GameResponse.self)
                .map(GameResponse.toDomain)
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func create(game: LoadableSubject<Game>, initialBet: Int, color: Color, bombs: Int) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        let colorId = Game.colors.firstIndex(of: color)!

        provider
                .requestPublisher(.createGame(initialBet: initialBet, bombs: bombs, colorId: colorId))
                .map(GameProfileResponse.self)
                .map(GameProfileResponse.toDomain)
                .map {
                    if let profile = $0.profile {
                        appState.value.consume(profile: profile)
                    }
                    return $0.game
                }
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        game.wrappedValue = game.wrappedValue.map {
            var game = $0
            game.tiles[tileId] = .loading
            return game
        }

        provider
                .requestPublisher(.guess(gameId: gameId, tileId: tileId))
                .map(GameProfileResponse.self)
                .map(GameProfileResponse.toDomain)
                .map {
                    if let profile = $0.profile {
                        appState.value.consume(profile: profile)
                    }
                    return $0.game
                }
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func cashOut(game: LoadableSubject<Game>, gameId: String) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        provider
                .requestPublisher(.cashOut(gameId: gameId))
                .map(GameProfileResponse.self)
                .map(GameProfileResponse.toDomain)
                .map {
                    if let profile = $0.profile {
                        appState.value.consume(profile: profile)
                    }
                    return $0.game
                }
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func delete(gameId: String) {
        weak var weakAppState = appState

        provider
                .requestPublisher(.deleteGame(id: gameId))
                .sinkToResult { result in
                    switch result {

                    case .success:
                        guard let games = weakAppState?[\.userData.games].map({ games -> [Game] in
                            var mutableGames = games
                            mutableGames.removeAll(where: { $0.id == gameId })
                            return mutableGames
                        }) else {
                            return
                        }

                        withAnimation {
                            weakAppState?[\.userData.games] = games
                        }
                    case let .failure(err):
                        print(err.localizedDescription)
                    }
                }
                .store(in: globalCancelBag)
    }
}

struct StubGameService: GameService {

    func loadGames() {

    }

    func load(game: LoadableSubject<Game>, gameId: String) {

    }

    func create(game: LoadableSubject<Game>, initialBet: Int, color: Color, bombs: Int) {

    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {

    }

    func cashOut(game: LoadableSubject<Game>, gameId: String) {

    }

    func delete(gameId: String) {

    }
}

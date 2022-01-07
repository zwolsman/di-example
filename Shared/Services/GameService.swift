//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Combine
import Foundation
import SwiftUI
import Moya

protocol GameService {
    func loadGames()
    func load(game: LoadableSubject<Game>, gameId: String)
    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String)

    func create(game: LoadableSubject<Game>, initialBet: Int, color: Color, bombs: Int)
    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int)
    func cashOut(game: LoadableSubject<Game>, gameId: String)

    func removeGames(ids: [String])
}

struct GamesResponse: Decodable {
    var games: [GameResponse]
}

struct GameResponse: Decodable {
    var id: String
    var tiles: [String]
    var stake: Int
    var next: Int?
    var multiplier: Double
    var state: State
    var secret: String
    var plain: String?

    enum State: String, Codable {
        case inGame = "IN_GAME"
        case hitBomb = "HIT_BOMB"
        case cashedOut = "CASHED_OUT"
    }
}

extension Tile {
    static func from(string source: String) -> (tileId: Int, tile: Tile)? {
        let tileTypeIndex = source.index(source.startIndex, offsetBy: 2)
        let stateIndex = source.index(after: tileTypeIndex)

        guard let tileId = Int(source[..<tileTypeIndex]) else {
            return nil
        }

        let state = source[stateIndex...]
        switch source[tileTypeIndex] {
        case "B":
            switch state {
            case "T", "F":
                return (tileId, .bomb(revealedByUser: state == "T"))
            default:
                return nil
            }
        case "P":
            let amount = Int(state)!
            return (tileId, .points(amount: amount))
        default:
            return nil
        }
    }
}

extension GameResponse {

    static func toDomain(response: Self) -> Game {
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
                color: .red,
                isActive: response.state == .inGame,
                isCashedOut: response.state == .cashedOut,
                lastTile: orderedTiles.last?.tile
        )
    }
}

struct RemoteGameService: GameService {
    let appState: Store<AppState>
    let provider: MoyaProvider<APIRepository>

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

    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String) {

    }

    func create(game: LoadableSubject<Game>, initialBet: Int, color: Color, bombs: Int) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        let colorId = Game.colors.firstIndex(of: color)!

        provider
                .requestPublisher(.createGame(initialBet: initialBet, bombs: bombs, colorId: colorId))
                .map(GameResponse.self)
                .map(GameResponse.toDomain)
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        provider
                .requestPublisher(.guess(gameId: gameId, tileId: tileId))
                .map(GameResponse.self)
                .map(GameResponse.toDomain)
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
                .map(GameResponse.self)
                .map(GameResponse.toDomain)
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func removeGames(ids: [String]) {

    }
}

struct StubGameService: GameService {

    func loadGames() {

    }

    func load(game: LoadableSubject<Game>, gameId: String) {

    }

    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String) {

    }

    func create(game: LoadableSubject<Game>, initialBet: Int, color: Color, bombs: Int) {

    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {

    }

    func cashOut(game: LoadableSubject<Game>, gameId: String) {

    }

    func removeGames(ids: [String]) {

    }
}

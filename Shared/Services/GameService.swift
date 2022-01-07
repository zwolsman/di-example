//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Combine
import Foundation
import SwiftUI
import Moya

protocol GameService {
    func refreshGames() -> AnyPublisher<Void, Error>
    func loadGames()
    func load(game: LoadableSubject<Game>, gameId: String)
    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String)

    func create(initialBet: Int, color: Color, bombs: Int) async -> String
    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) async -> Tile?
    func cashOut(game: LoadableSubject<Game>, gameId: String) async -> Int

    func removeGames(ids: [String])
}

class LocalGameService: GameService {
    let appState: Store<AppState>
    private var gameStore: [String: RemoteGame] = [:] {
        didSet {
            let cancelBag = CancelBag()
            weak var weakAppState = appState
            Just(gameStore.values.map {
                $0.toGame()
            })
                    .sinkToLoadable {
                        weakAppState?[\.userData.games] = $0
                    }
                    .store(in: cancelBag)
        }
    }
    private var repo: GameRepository

    init(appState: Store<AppState>, repo: GameRepository) {
        self.appState = appState
        self.repo = repo
    }

    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func loadGames() {
        let cancelBag = CancelBag()
        appState[\.userData.games].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        Just(gameStore.values.map {
            $0.toGame()
        })
                .sinkToLoadable {
                    weakAppState?[\.userData.games] = $0
                }
                .store(in: cancelBag)
    }

    func load(game: LoadableSubject<Game>, gameId: String) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        guard let localGame = gameStore[gameId]?.toGame() else {
            game.wrappedValue = .failed(gameNotFoundError)
            return
        }

        Just(localGame)
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String) {
        let cancelBag = CancelBag()
        gameDetails.wrappedValue.setIsLoading(cancelBag: cancelBag)

        guard let remoteGame = gameStore[gameId] else {
            gameDetails.wrappedValue = .failed(gameNotFoundError)
            return
        }

        let details = remoteGame.toDetails()

        Just(details)
                .sinkToLoadable {
                    gameDetails.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func create(initialBet: Int, color: Color, bombs: Int) async -> String {
        let game = await repo.createGame(initialStake: initialBet, bombs: bombs, colorId: Game.colors.firstIndex(of: color)!)

        appState[\.userData.profile] = appState[\.userData.profile].map { profile in
            var mutableProfile = profile
            mutableProfile.points -= initialBet
            return mutableProfile
        }

        gameStore[game.id] = game
        return game.id
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) async -> Tile? {
        do {
            let (result, remoteGame) = try await repo.guess(tileId: tileId, gameId: gameId)
            checkGameState(remoteGame: remoteGame)
            gameStore[gameId] = remoteGame
            game.wrappedValue = .loaded(remoteGame.toGame())

            return result
        } catch {
            game.wrappedValue = .failed(error)
            return nil
        }
    }

    func cashOut(game: LoadableSubject<Game>, gameId: String) async -> Int {
        do {
            let remoteGame = try await repo.cashOut(gameId: gameId)
            checkGameState(remoteGame: remoteGame)
            gameStore[gameId] = remoteGame
            game.wrappedValue = .loaded(remoteGame.toGame())
            return remoteGame.stake
        } catch {
            game.wrappedValue = .failed(error)
            return 0
        }
    }

    private func checkGameState(remoteGame: RemoteGame) {
        guard remoteGame.state != .inGame else {
            return
        }
        let profile = appState[\.userData.profile].map { profile -> Profile in
            var mutableProfile = profile
            mutableProfile.games += 1
            if case .gameOver(.cashedOut) = remoteGame.state {
                mutableProfile.totalEarnings += remoteGame.stake - remoteGame.initialBet
                mutableProfile.points += remoteGame.stake
            }

            return mutableProfile
        }

        appState[\.userData.profile] = profile
    }

    func removeGames(ids: [String]) {
        for id in ids {
            gameStore.removeValue(forKey: id)
        }
    }

    private var gameNotFoundError: Error {
        NSError(
                domain: NSCocoaErrorDomain, code: NSUserCancelledError,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Game not found", comment: "")])
    }
}

struct GameResponse: Decodable {
    var id: String
    var tiles: [String]
    var stake: Int
    var next: Int
    var state: State
    var secret: String
    var plain: String?

    enum State: String, Codable {
        case inGame = "IN_GAME"
        case hitBomb = "HIT_BOMB"
        case cashedOut = "CASHED_OUT"
    }
}

extension GameResponse {

    static func toDomain(response: Self) -> Game {
        let tiles = response.tiles.reduce(into: [Int: Tile]()) { result, tile in
            let tileTypeIndex = tile.index(tile.startIndex, offsetBy: 2)
            let stateIndex = tile.index(after: tileTypeIndex)

            let tileId = Int(tile[..<tileTypeIndex])!
            let state = tile[stateIndex...]
            switch tile[tileTypeIndex] {
            case "B":
                if state == "T" {
                    result[tileId] = .bomb(revealedByUser: true)
                }
                if state == "F" {
                    result[tileId] = .bomb(revealedByUser: false)
                }
                break
            case "P":
                let amount = Int(state)!
                result[tileId] = .points(amount: amount)
            default:
                break
            }
        }

        return Game(id: response.id, tiles: tiles, secret: response.secret, stake: response.stake, next: response.next, multiplier: 1, color: .red, isActive: response.state == .inGame)
    }
}

struct RemoteGameService: GameService {
    let appState: Store<AppState>
    let provider: MoyaProvider<APIRepository>

    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func loadGames() {
        let cancelBag = CancelBag()
        appState[\.userData.games].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        provider
                .requestPublisher(.games)
                .map([GameResponse].self)
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

    func create(initialBet: Int, color: Color, bombs: Int) async -> String {
        ""
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) async -> Tile? {
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

        return nil
    }

    func cashOut(game: LoadableSubject<Game>, gameId: String) async -> Int {
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

        return 0
    }

    func removeGames(ids: [String]) {

    }
}

private extension RemoteGame {
    func toGame() -> Game {
        Game(id: id, tiles: tiles, secret: secret, stake: stake, next: next, multiplier: multiplier, color: Game.colors[colorId], isActive: state == .inGame)
    }

    func toDetails() -> Game.Details {
        Game.Details(initialStake: initialBet, stake: stake, multiplier: multiplier, bombs: bombs, color: Game.colors[colorId], secret: secret, plain: plain)
    }
}

struct StubGameService: GameService {
    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func loadGames() {

    }

    func load(game: LoadableSubject<Game>, gameId: String) {

    }

    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String) {

    }

    func create(initialBet: Int, color: Color, bombs: Int) async -> String {
        ""
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) async -> Tile? {
        nil
    }

    func cashOut(game: LoadableSubject<Game>, gameId: String) async -> Int {
        0
    }

    func removeGames(ids: [String]) {

    }
}

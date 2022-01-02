//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Combine
import Foundation
import SwiftUI

protocol GameService {
    func refreshGames() -> AnyPublisher<Void, Error>
    func loadGames()
    func load(game: LoadableSubject<Game>, gameId: String)
    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String)

    func create(initialBet: Int, color: Color, bombs: Int) async -> String
    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) async -> Tile?
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

        gameStore[game.id] = game
        return game.id
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) async -> Tile? {
        do {
            let (result, remoteGame) = try await repo.guess(tileId: tileId, gameId: gameId)

            gameStore[gameId] = remoteGame
            game.wrappedValue = .loaded(remoteGame.toGame())

            return result
        } catch {
            game.wrappedValue = .failed(gameNotFoundError)
            return nil
        }
    }

    private var gameNotFoundError: Error {
        NSError(
                domain: NSCocoaErrorDomain, code: NSUserCancelledError,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Game not found", comment: "")])
    }
}

private extension RemoteGame {
    func toGame() -> Game {
        Game(id: id, tiles: tiles, secret: secret, stake: stake, bet: initialBet, next: next, color: Game.colors[colorId])
    }

    func toDetails() -> Game.Details {
        Game.Details(initialStake: initialBet, stake: stake, bombs: 0, color: Game.colors[colorId], secret: secret, plain: plain)
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
}

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

    func create(initialBet: Int, color: Color, bombs: Int)
    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int)
}

class LocalGameService: GameService {
    let appState: Store<AppState>
    private var gameStore: [String: Game] = [:] {
        didSet {
            let cancelBag = CancelBag()
            weak var weakAppState = appState
            Just(Array(gameStore.values))
                    .sinkToLoadable {
                        weakAppState?[\.userData.games] = $0
                    }
                    .store(in: cancelBag)
        }
    }

    init(appState: Store<AppState>) {
        self.appState = appState
    }

    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func loadGames() {
        let cancelBag = CancelBag()
        appState[\.userData.games].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        Just(Array(gameStore.values))
                .delay(for: 2, scheduler: RunLoop.main)
                .sinkToLoadable {
                    weakAppState?[\.userData.games] = $0
                }
                .store(in: cancelBag)
    }

    func load(game: LoadableSubject<Game>, gameId: String) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        guard let localGame = gameStore[gameId] else {
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

        guard let game = gameStore[gameId] else {
            gameDetails.wrappedValue = .failed(gameNotFoundError)
            return
        }

        let details = Game.Details(initialStake: game.stake, stake: game.stake, bombs: game.bombs, color: game.color, secret: game.secret, plain: nil)

        Just(details)
                .sinkToLoadable {
                    gameDetails.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func create(initialBet: Int, color: Color, bombs: Int) {
        let game = Game(secret: "secret", stake: 100, bet: 100, next: 15, color: color, bombs: bombs)
        gameStore[game.id] = game
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        guard var currentGame = gameStore[gameId] else {
            game.wrappedValue = .failed(gameNotFoundError)
            return
        }

        currentGame.stake *= 2
        gameStore[gameId] = currentGame
        game.wrappedValue = .loaded(currentGame)
    }

    private func findGame(gameId: String) -> Game? {
        let games = appState[\.userData.games].value ?? []

        return games.first(where: { $0.id == gameId })
    }

    private var gameNotFoundError: Error {
        NSError(
                domain: NSCocoaErrorDomain, code: NSUserCancelledError,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Game not found", comment: "")])
    }
}

struct StubGamesInteractor: GameService {
    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func loadGames() {

    }

    func load(game: LoadableSubject<Game>, gameId: String) {

    }

    func load(gameDetails: LoadableSubject<Game.Details>, gameId: String) {

    }

    func create(initialBet: Int, color: Color, bombs: Int) {

    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {

    }
}
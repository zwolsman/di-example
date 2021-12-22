//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Combine

protocol GameService {
    func refreshGames() -> AnyPublisher<Void, Error>
    func loadGames()
    func load(game: LoadableSubject<Game>, id: String)

    func create()
}

struct LocalGameService: GameService {
    let appState: Store<AppState>

    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func loadGames() {
        let cancelBag = CancelBag()
        appState[\.userData.games].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        Just<[Game]>(appState[\.userData.games].value ?? [])
                .sinkToLoadable {
                    weakAppState?[\.userData.games] = $0
                }
                .store(in: cancelBag)
    }

    func load(game: LoadableSubject<Game>, id: String) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)
        let games = appState[\.userData.games].value ?? []

        let localGame = games.first(where: { $0.id == id })!

        Just(localGame)
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func create() {
        let game = Game(status: true, secret: "secret", stake: 100, bet: 100, next: 15)
        let cancelBag = CancelBag()
        appState[\.userData.games].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        var games = appState[\.userData.games].value ?? []
        games.insert(game, at: 0)

        Just(games)
                .sinkToLoadable {
                    weakAppState?[\.userData.games] = $0
                }.store(in: cancelBag)
    }
}

struct StubGamesInteractor: GameService {
    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func loadGames() {

    }

    func load(game: LoadableSubject<Game>, id: String) {

    }

    func create() {

    }
}
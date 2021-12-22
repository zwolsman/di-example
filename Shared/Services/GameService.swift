//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Combine

protocol GameService {
    func refreshGames() -> AnyPublisher<Void, Error>
    func load(games: LoadableSubject<[Game]>)
    func load(game: LoadableSubject<Game>, id: String)
}

class LocalGameService: GameService {

    var localGames: [Game] = []

    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func load(games: LoadableSubject<[Game]>) {
        let cancelBag = CancelBag()
        games.wrappedValue.setIsLoading(cancelBag: cancelBag)
        Just<[Game]>(localGames)
                .sinkToLoadable {
                    games.wrappedValue = $0
                }.store(in: cancelBag)
    }

    func load(game: LoadableSubject<Game>, id: String) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)
        let localGame = localGames.first(where: { $0.id == id })

        Just(localGame!)
                .sinkToLoadable {
                    game.wrappedValue = $0
                }.store(in: cancelBag)
    }
}

struct StubGamesInteractor: GameService {
    func refreshGames() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func load(games: LoadableSubject<[Game]>) {

    }

    func load(game: LoadableSubject<Game>, id: String) {

    }
}
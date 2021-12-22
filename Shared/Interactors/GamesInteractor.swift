//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Combine

protocol GamesInteractor {
    func refreshGamesList() -> AnyPublisher<Void, Error>
    func load(games: LoadableSubject<[Game]>)
    func load(game: LoadableSubject<Game>, id: String)
}

struct LocalGamesInteractor: GamesInteractor {
    func refreshGamesList() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func load(games: LoadableSubject<[Game]>) {
        let cancelBag = CancelBag()
        games.wrappedValue.setIsLoading(cancelBag: cancelBag)
        Just<[Game]>([Game(id: "test")])
                .sinkToLoadable {
                    games.wrappedValue = $0
                }.store(in: cancelBag)
    }

    func load(game: LoadableSubject<Game>, id: String) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)
        Just<Game>(Game(id: id))
                .sinkToLoadable {
                    game.wrappedValue = $0
                }.store(in: cancelBag)
    }
}

struct StubGamesInteractor: GamesInteractor {
    func refreshGamesList() -> AnyPublisher<Void, Error> {
        Just<Void>.withErrorType(Error.self)
    }

    func load(games: LoadableSubject<[Game]>) {

    }

    func load(game: LoadableSubject<Game>, id: String) {

    }
}
//
// Created by Marvin Zwolsman on 22/12/2021.
//

extension DIContainer {
    struct Interactors {
        let gamesInteractor: GamesInteractor

        static var stub: Self {
            .init(gamesInteractor: StubGamesInteractor())
        }
    }
}
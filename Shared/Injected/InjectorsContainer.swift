//
// Created by Marvin Zwolsman on 22/12/2021.
//

extension DIContainer {
    struct Interactors {
        let gameService: GameService

        static var stub: Self {
            .init(gameService: StubGamesInteractor())
        }
    }
}
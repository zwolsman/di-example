//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

// MARK: - Routing

extension GameScene {
    struct Routing: Equatable {

    }
}

// MARK: - ViewModel

extension GameScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var game: Loadable<Game>

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        let gameId: String

        init(container: DIContainer, id: String, game: Loadable<Game> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.gameScene)
            _game = .init(initialValue: game)
            gameId = id

            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.gameScene] = $0
                        }
                appState.map(\.routing.gameScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        // MARK: - Side Effects

        func loadGame() {
            container.services.gameService
                    .load(game: loadableSubject(\.game), gameId: gameId)
        }

        func guess(tileId: Int) {
            container.services.gameService.guess(game: loadableSubject(\.game), gameId: gameId, tileId: tileId)
        }
    }
}
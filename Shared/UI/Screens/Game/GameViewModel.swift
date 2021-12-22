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
        private let id: String

        init(container: DIContainer, id: String, game: Loadable<Game> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.gameScene)
            _game = .init(initialValue: game)
            self.id = id

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
            container.interactors.gamesInteractor
                    .load(game: loadableSubject(\.game), id: id)
        }
    }
}
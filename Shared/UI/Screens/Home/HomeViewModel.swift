//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

// MARK: - Routing

extension HomeScene {
    struct Routing: Equatable {
        var gameDetails: String?
    }
}

// MARK: - ViewModel

extension HomeScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var games: Loadable<[Game]>

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer, games: Loadable<[Game]> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.homeScene)
            _games = .init(initialValue: games)

            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.homeScene] = $0
                        }
                appState.map(\.routing.homeScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
                appState.map(\.userData.games)
                        .weakAssign(to: \.games, on: self)
            }
        }

        // MARK: - Side effects

        func loadGames() {
            container.services.gameService.loadGames()
        }

    }
}
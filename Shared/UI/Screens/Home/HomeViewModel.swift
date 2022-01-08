//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

// MARK: - Routing

extension HomeScene {
    struct Routing: Equatable {
        var gameId: String?
        var showNewGameScene = false
        var showProfileScene = false
    }
}

// MARK: - ViewModel

extension HomeScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var games: Loadable<[Game]>
        @Published var profile: Loadable<Profile>

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(
                container: DIContainer,
                games: Loadable<[Game]> = .notRequested,
                profile: Loadable<Profile> = .notRequested
        ) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.homeScene)
            _games = .init(initialValue: games)
            _profile = .init(initialValue: profile)

            cancelBag.collect {
                $routingState
                        .removeDuplicates()
                        .sink {
                            appState[\.routing.homeScene] = $0
                        }
                appState
                        .updates(for: \.routing.homeScene)
                        .weakAssign(to: \.routingState, on: self)

                appState
                        .updates(for: \.userData.games)
                        .weakAssign(to: \.games, on: self)

                appState
                        .updates(for: \.userData.profile)
                        .weakAssign(to: \.profile, on: self)
            }
        }

        // MARK: - Side effects

        func loadGames() {
            container.services.gameService.loadGames()
        }

        func loadProfile() {
            container.services.profileService.loadMe()
        }

        func deleteGame(id: String) {
            container.services.gameService.removeGames(ids: [id])
        }

        func refresh() async {
            loadGames()
            loadProfile()
        }
    }
}

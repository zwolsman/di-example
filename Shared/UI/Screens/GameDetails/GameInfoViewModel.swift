//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

// MARK: - Routing

extension GameInfoScene {
    struct Routing: Equatable {

    }
}

extension GameInfoScene {

    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var gameDetails: Loadable<Game.Details>
        @Published var showPlain: Bool = false

        var secret: String {
            "\n" + (gameDetails.value?.secret ?? "") + "\n"
        }

        var plain: String {
            "\n" + (gameDetails.value?.plain ?? "") + "\n"
        }


        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        var gameId: String

        init(container: DIContainer, gameId: String, gameDetails: Loadable<Game.Details> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.gameDetailsScene)
            _gameDetails = .init(initialValue: gameDetails)
            self.gameId = gameId
            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.gameDetailsScene] = $0
                        }
                appState.map(\.routing.gameDetailsScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        func loadGameDetails() {
            container.services.gameService.load(gameDetails: loadableSubject(\.gameDetails), gameId: gameId)
        }

        func toggleSecret() {
            showPlain.toggle()
        }
    }
}
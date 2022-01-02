//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI

// MARK: - Routing

extension NewGameScene {
    struct Routing: Equatable {

    }
}

// MARK: - ViewModel

extension NewGameScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var color: Color = Game.colors[0]
        @Published var bombs: Bombs = .three
        @Published var bet: Int = 100

        var canCreateGame: Bool {
            true
        }

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.newGameScene)
            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.newGameScene] = $0
                        }
                appState.map(\.routing.newGameScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        // MARK: - Side effects

        func createGame() {
            Task {
                let id = await container
                        .services
                        .gameService
                        .create(initialBet: bet, color: color, bombs: bombs.rawValue)
                print("created game with id: \(id)")

                container.appState.bulkUpdate { state in
                    state.routing.homeScene.showNewGameScene = false
                    state.routing.homeScene.gameId = id

                    // TODO: make this pretty :)
                    guard var profile = state.userData.profile.value else {
                        return
                    }
                    profile.points -= bet
                    state.userData.profile = .loaded(profile)
                }
            }
        }
    }
}

extension NewGameScene {
    enum Bombs: Int, CaseIterable {
        case one = 1
        case three = 3
        case five = 5
        case twentyFour = 24
    }
}
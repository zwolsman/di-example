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
        @Published var pointsText: String = "100"

        var points: Int? {
            Int.from(string: pointsText)
        }

        @Published var newGame: Loadable<Game> = .notRequested

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

        // MARK: - Creating game
        func createGame() {
            let game = loadableSubject(\.newGame).onSet { [weak self] game in
                guard case let .loaded(game) = game else {
                    return
                }
                self?.gameCreated(game)
            }
            guard let points = points else {
                print("Points are invalid")
                return
            }

            container
                    .services
                    .gameService
                    .create(game: game, initialBet: points, color: color, bombs: bombs.rawValue)
        }

        private func gameCreated(_ game: Game) {
            container.appState.bulkUpdate { state in
                switch state.userData.games {
                case .notRequested:
                    state.userData.games = .loaded([game])
                case let .isLoading(last, cb):
                    guard var previousGames = last else {
                        state.userData.games = .isLoading(last: [game], cancelBag: cb)
                        break
                    }
                    previousGames.insert(game, at: 0)
                    state.userData.games = .isLoading(last: previousGames, cancelBag: cb)
                case var .loaded(games):
                    games.insert(game, at: 0)
                    state.userData.games = .loaded(games)
                default:
                    break
                }

                state.routing.homeScene.showNewGameScene = false
                state.routing.homeScene.gameId = game.id
            }
        }

        // MARK: - Modify points

        func setToMinPoints() {
            pointsText = "100"
        }

        func setToMaxPoints() {
            guard let profile = container.appState[\.userData.profile].value else {
                return
            }
            pointsText = "\(profile.points.formatted())"
        }

        func resetPoints() {
            pointsText = "0"
        }

        func modifyPoints(_ diff: Int) {
            guard let points = points else {
                return
            }
            pointsText = "\((points + diff).formatted())"
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
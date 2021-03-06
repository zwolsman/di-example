//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI
import Moya

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
        @Published var color: Color
        @Published var bombs: Bombs
        @Published var pointsText: String

        var points: Int? {
            Int.from(string: pointsText)
        }

        var pointsRange: ClosedRange<Int> {
            var end: Int
            if let points = container.appState[\.userData.profile].value?.points {
                end = points
            } else {
                end = Int.max
            }
            return 0...end
        }

        @Published
        var newGame: Loadable<Game> = .notRequested {
            didSet {
                switch newGame {
                case let .loaded(game):
                    gameCreated(game)
                case .failed:
                    problem = newGame.problem
                default:
                    break
                }
            }
        }

        var problem: Problem?

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

            if let lastGame = appState.value.userData.games.value?.first {
                color = lastGame.color
                bombs = .init(rawValue: lastGame.bombs) ?? .three
                pointsText = lastGame.initialBet.formatted()
            } else {
                color = Game.colors[0]
                bombs = .three
                pointsText = "100"
            }

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
            guard let points = points else {
                print("Points are invalid")
                return
            }

            container
                    .services
                    .gameService
                    .create(game: loadableSubject(\.newGame), initialBet: points, color: color, bombs: bombs.rawValue)
        }

        private func gameCreated(_ game: Game) {
            container.appState.bulkUpdate { state in
                state.consume(game: game)
                state.routing.homeScene.showNewGameScene = false
                state.routing.homeScene.gameId = game.id
            }
        }

        // MARK: - Modify points

        func setToMinPoints() {
            pointsText = "100"
        }

        func setToMaxPoints() {
            pointsText = "\(pointsRange.upperBound.formatted())"
        }

        func doublePoints() {
            guard let points = points else {
                return
            }
            pointsText = (points * 2).formatted()
        }

        func modifyPoints(_ diff: Int) {
            guard let points = points else {
                return
            }

            let diff = clamped(points + diff, to: pointsRange)
            pointsText = "\(diff.formatted())"
        }

        private func clamped(_ num: Int, to range: ClosedRange<Int>) -> Int {
            max(min(num, range.upperBound), range.lowerBound)
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

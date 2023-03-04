//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI
import Moya

// MARK: - Routing

extension NewGameScene {
    struct Routing: Equatable {
        var game: Game? = nil
    }
}

// MARK: - ViewModel

extension NewGameScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var color: Color
        @Published var bombs: Int
        @Published var pointsText: String
        @Published var profile: Loadable<Profile>
        
        var points: Int? {
            Int.from(string: pointsText)
        }
        
        var level: String {
            switch bombs {
            case 1:
                return "easy"
            case 2, 3:
                return "avg"
            case 4, 5:
                return "hard"
            default:
                return "level"
            }
        }
        
        var levelColor: String {
            switch bombs {
            case 1:
                return "easy"
            case 2:
                return "medium"
            case 3:
                return "medium-2"
            case 4, 5:
                return "hard"
            default:
                return "not set"
            }
        }
        
        var pointsRange: ClosedRange<Int> {
            guard let userPoints = container.appState[\.userData.profile].value?.points else {
                return 0...0
            }
            
            if userPoints < 100 {
                return 0...0
            }
            
            return 100...userPoints
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
            guard 1...5 ~= bombs else {
                return false
            }
            
            guard let points else {
                return false
            }
            
            return pointsRange.contains(points)
        }
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, profile: Loadable<Profile> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.newGameScene)
            _profile = .init(initialValue: profile)
            
            color = Game.colors[0]
            bombs = 0
            pointsText = "100"
            
            cancelBag.collect {
                $routingState
                    .sink {
                        appState[\.routing.newGameScene] = $0
                    }
                appState.map(\.routing.newGameScene)
                    .removeDuplicates()
                    .weakAssign(to: \.routingState, on: self)
                appState
                        .updates(for: \.userData.profile)
                        .weakAssign(to: \.profile, on: self)
            }
        }
        
        // MARK: - Side effects
        
        func loadProfile() {
            container.services.profileService.loadMe()
        }
        
        // MARK: - Creating game
        func createGame() {
            guard let points = points else {
                print("Points are invalid")
                return
            }
            
            container
                .services
                .gameService
                .create(game: loadableSubject(\.newGame), initialBet: points, color: color, bombs: bombs)
        }
        
        private func gameCreated(_ game: Game) {
            container.appState.bulkUpdate { state in
//                state.consume(game: game)
                state.routing.newGameScene.game = game
            }
        }
        
        // MARK: - Modify points
        
        func setToMinPoints() {
            pointsText = "\(pointsRange.lowerBound.formatted())"
        }
        
        func setToMaxPoints() {
            pointsText = "\(pointsRange.upperBound.formatted())"
        }
        
        private func clamped(_ num: Int, to range: ClosedRange<Int>) -> Int {
            max(min(num, range.upperBound), range.lowerBound)
        }
    }
}

//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI
import UIKit
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
        @Published var newGame: Loadable<Game> = .notRequested
        @Published var isInGame: Bool = false
        
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

                $newGame
                    .sink {
                        appState[\.routing.newGameScene.game] = $0.value
                    }
                
                appState
                    .updates(for: \.routing.gameScene.game)
                    .receive(on: RunLoop.main) // TODO: why?
                    .weakAssign(to: \.routingState.game, on: self)

                appState
                    .updates(for: \.routing.newGameScene)
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
            guard let points else {
                print("Points are invalid")
                return
            }
            
            isInGame = true
            container
                .services
                .gameService
                .create(game: loadableSubject(\.newGame), initialBet: points, color: color, bombs: bombs)
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

//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI

// MARK: - Routing

extension GameInfoScene {
    struct Routing: Equatable {

    }
}

extension GameInfoScene {

    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var game: Game
        @Published var showPlain: Bool = false
        @Published var abbreviatePoints: Bool = true

        var secret: String {
            return game.secret.chunked(into: 4).joined(separator: " ")
        }

        var hasPlain: Bool {
            return game.plain != nil
        }

        var plain: String {
            guard let plain = game.plain else {
                return "\n\n\n"
            }

            return "\n\(plain)\n"
        }

        var initialStake: String {
            if abbreviatePoints {
                return game.initialBet.abbr()
            } else {
                return game.initialBet.formatted()
            }
        }

        var stake: String {
            if abbreviatePoints {
                return game.stake.abbr()
            } else {
                return game.stake.formatted()
            }
        }

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer, game: Game) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.gameDetailsScene)
            _game = .init(initialValue: game)
            
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

        func toggleAbbreviatePoints() {
            abbreviatePoints.toggle()
        }

        func copySecret() {
            guard let plain = game.plain else { return }
            UIPasteboard.general.string = plain
        }
        
        func copyChecksum() {
            UIPasteboard.general.string = secret
        }
        
        func toggleSecret() {
            if hasPlain {
                showPlain.toggle()
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

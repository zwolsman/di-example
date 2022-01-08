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
        @Published var game: Loadable<Game>
        @Published var showPlain: Bool = false
        @Published var abbreviatePoints: Bool = true

        var secret: String {
            guard let game = game.value else {
                return ""
            }

            return game.secret.chunked(into: 4).joined(separator: " ")
        }

        var hasPlain: Bool {
            guard let _ = game.value?.plain else {
                return false
            }
            return true
        }

        var plain: String {
            guard let plain = game.value?.plain else {
                return "\n\n\n"
            }

            return "\n\(plain)\n"
        }

        var initialStake: String {
            guard let game = game.value else {
                return ""
            }

            if abbreviatePoints {
                return game.initialBet.abbr()
            } else {
                return game.initialBet.formatted()
            }
        }

        var stake: String {
            guard let game = game.value else {
                return ""
            }

            if abbreviatePoints {
                return game.stake.abbr()
            } else {
                return game.stake.formatted()
            }
        }

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        var gameId: String

        init(container: DIContainer, gameId: String, game: Loadable<Game> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.gameDetailsScene)
            _game = .init(initialValue: game)
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

        func loadGame() {
            container.services.gameService.load(game: loadableSubject(\.game), gameId: gameId)
        }

        func toggleAbbreviatePoints() {
            abbreviatePoints.toggle()
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

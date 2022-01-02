//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI

// MARK: - Routing

extension GameScene {
    struct Routing: Equatable {

    }
}

// MARK: - ViewModel

extension GameScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var game: Loadable<Game>

        var tiles: [TileButton.Configuration] {
            Game.TILE_RANGE.map(createTileButtonConfig(tileId:))
        }

        var canPlay: Bool {
            guard case let Loadable.loaded(game) = game else {
                return false
            }
            return game.state == .inGame
        }

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        let gameId: String

        init(container: DIContainer, id: String, game: Loadable<Game> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.gameScene)
            _game = .init(initialValue: game)
            gameId = id

            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.gameScene] = $0
                        }
                appState.map(\.routing.gameScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        // MARK: - Side Effects

        func loadGame() {
            container.services.gameService
                    .load(game: loadableSubject(\.game), gameId: gameId)
        }

        func cashOut() {
            Task {
                let (stake, earnings) = await container.services.gameService
                        .cashOut(game: loadableSubject(\.game), gameId: gameId)
                updateProfile(stake: stake, earnings: earnings)
                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }

        func guess(tileId: Int) {
            Task {
                guard let result = await container.services.gameService.guess(game: loadableSubject(\.game), gameId: gameId, tileId: tileId) else {
                    return
                }

                switch result {
                case .bomb(_):
                    await UINotificationFeedbackGenerator().notificationOccurred(.error)
                    updateProfile(stake: 0, earnings: 0)
                case .points(_):
                    await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }

        private func updateProfile(stake: Int, earnings: Int) {
            container.appState.bulkUpdate { state in
                // TODO: make this pretty :)
                guard var profile = state.userData.profile.value else {
                    return
                }
                profile.games += 1
                profile.points += stake
                profile.totalEarnings += earnings
                state.userData.profile = .loaded(profile)
            }
        }

        private func createTileButtonConfig(tileId: Int) -> TileButton.Configuration {
            guard case let Loadable.loaded(game) = game else {
                return TileButton.Configuration(id: tileId)
            }
            return TileButton.Configuration(
                    id: tileId,
                    tile: game.tiles[tileId],
                    color: game.color
            ) { [weak self] in
                self?.guess(tileId: tileId)
            }
        }
    }
}

// MARK: - Tile state

extension TileButton {
    struct Configuration: Identifiable {
        var id: Int
        var tile: Tile?
        var color: Color = .clear
        var action: () -> Void = {
        }
    }
}

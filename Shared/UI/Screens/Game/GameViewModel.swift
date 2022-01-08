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
            Game.tileRange.map(createTileButtonConfig(tileId:))
        }

        var canPlay: Bool {
            guard case let Loadable.loaded(game) = game else {
                return false
            }
            return game.isActive
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
                $game
                        .removeDuplicates()
                        .sink {
                            guard case let .loaded(game) = $0 else {
                                return
                            }
                            appState.value.consume(game: game)
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
            let gameSubject = loadableSubject(\.game).onSet { [weak self] game in
                guard case let .loaded(game) = game else {
                    return
                }
                self?.cashOutFeedback(game: game)
            }

            container
                    .services
                    .gameService
                    .cashOut(game: gameSubject, gameId: gameId)

        }

        func guess(tileId: Int) {
            // TODO: ideal world
            // loadableSubject(\.game).onLoaded(notificationFeedback(game:))
            let gameSubject = loadableSubject(\.game).onSet { [weak self] game in
                guard case let .loaded(game) = game else {
                    return
                }

                self?.guessFeedback(game: game)
            }

            container
                    .services
                    .gameService
                    .guess(game: gameSubject, gameId: gameId, tileId: tileId)
        }

        private func createTileButtonConfig(tileId: Int) -> TileButton.Configuration {
            guard let game = game.value else {
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

        private func guessFeedback(game: Game) {
            guard let result = game.lastTile else {
                return
            }

            switch result {
            case .bomb:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .points:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            default:
                break
            }
        }

        private func cashOutFeedback(game: Game) {
            guard game.isCashedOut else {
                return
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
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

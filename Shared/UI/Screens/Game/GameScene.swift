//
//  GameDetailScene.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI
import Combine

struct GameScene: View {
    @ObservedObject private(set) var viewModel: ViewModel

    let inspection = Inspection<Self>()

    var body: some View {
        content
                .navigationBarTitle("Game", displayMode: .inline)
                .toolbar {
                    gameDetailsButton
                }
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.game {
        case .notRequested: notRequestedView
        case .isLoading: loadingView
        case let .loaded(gameDetails): loadedView(gameDetails)
        case let .failed(error): failedView(error)
        }
    }

    private var gameDetailsButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: GameInfoScene(viewModel: .init(container: viewModel.container, gameId: viewModel.gameId))) {
                Label("Game details", systemImage: "info.circle")
            }
        }
    }
}

// MARK: - Loading Content

private extension GameScene {
    var notRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadGame)
    }

    var loadingView: some View {
        VStack {
            ActivityIndicatorView()
            Button(action: {
                viewModel.game.cancelLoading()
            }, label: { Text("Cancel loading") })
        }
    }

    func failedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Content

private extension GameScene {
    private static let COLUMNS = Array(repeating: GridItem(.flexible()), count: 5)
    
    func loadedView(_ game: Game) -> some View {
        VStack {
            LazyVGrid(columns: GameScene.COLUMNS, spacing: 8) {
                ForEach(viewModel.tiles, content: TileButton.init(config:))
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(8)
            .layoutPriority(1)
            

            Text("Game: \(game.id)")
                    .font(.headline)

            Text("Stake: \(game.stake)")
                    .font(.subheadline)
        }
    }
    
    
}

struct GameDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        GameScene(viewModel: .init(container: .preview, id: Game.mockedData[0].id))
        
        GameScene(viewModel: .init(container: .preview, id: Game.mockedData[0].id, game: .loaded(Game.mockedData[0])))
    }
}

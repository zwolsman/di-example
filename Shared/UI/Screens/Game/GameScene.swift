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
        case let .isLoading(game, _): loadingView(game)
        case let .loaded(game): loadedView(game)
        case let .failed(error): failedView(error)
        }
    }
    
    private var gameInfoScene: GameInfoScene {
        .init(viewModel: .init(container: viewModel.container, gameId: viewModel.gameId, game: viewModel.game))
    }
    
    private var gameDetailsButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: gameInfoScene) {
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
    
    @ViewBuilder
    func loadingView(_ previouslyLoaded: Game?) -> some View {
        if let game = previouslyLoaded {
            loadedView(game)
        } else {
            HStack {
                ProgressView()
                    .padding(8)
                Text("Loading game")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func failedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Content

private extension GameScene {
    private static let COLUMNS = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    
    func loadedView(_ game: Game) -> some View {
        VStack {
            LazyVGrid(columns: GameScene.COLUMNS, spacing: 8) {
                ForEach(viewModel.tiles, content: TileButton.init(config:))
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(8)
            .layoutPriority(1)
            .allowsHitTesting(viewModel.canPlay)
            
            PointsGrid(items: [
                .init(name: "Next", amount: game.next?.formatted() ?? "-"),
                .init("Stake", amount: game.stake),
                .init("Multiplier", amount: game.multiplier)
            ])
            Divider().padding()

            VStack {
                Label("No events to show yet", systemImage: "tray")
                        .foregroundColor(.secondary)
            }.frame(maxHeight: .infinity)

            Divider().padding([.top, .leading, .trailing])
            
            Button("Cash out", action: viewModel.cashOut)
                .frame(maxWidth: .infinity)
                .padding(.top)
                .disabled(!viewModel.canPlay)
        }
    }
}

struct GameDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameScene(viewModel: .init(container: .preview, id: Game.mockedData[0].id,
                                       game: .isLoading(last: nil, cancelBag: CancelBag())))
        }
        NavigationView {
            GameScene(viewModel: .init(container: .preview, id: Game.mockedData[0].id, game: .loaded(Game.mockedData[1])))
        }
    }
}

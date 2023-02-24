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
                gameHeaderText
                gameDetailsButton
            }
            .onReceive(inspection.notice) {
                inspection.visit(self, $0)
            }
            .preferredColorScheme(.dark)
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
    private var gameHeaderText: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Game")
            .font(.custom("Carbon Bold",  size: UIFont.preferredFont(forTextStyle: .title3).pointSize)
            )
            .textCase(.uppercase)
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
            VStack {
                ActivityIndicatorView()
                Button(action: {
                    viewModel.game.cancelLoading()
                }, label: { Text("Cancel loading") })
            }
        }
    }
    
    func failedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Content

private extension GameScene {
    private static let COLUMNS = Array(repeating: GridItem(.flexible(), spacing: 1), count: 5)
    
    func loadedView(_ game: Game) -> some View {
        VStack {
            LazyVGrid(columns: GameScene.COLUMNS, spacing: 1) {
                ForEach(viewModel.tiles) { config in
                    TileButton(config: config)
                }
            }
            .padding(1)
            .background(Color("grey"))
            .padding(24)
            .aspectRatio(1, contentMode: .fit)
            .layoutPriority(1)
            .allowsHitTesting(viewModel.canPlay)
            .background(Color("grey two"), ignoresSafeAreaEdges: [])
            
            PointsGrid(items: [
                .init(name: "Next", amount: game.next?.formatted() ?? "-"),
                .init("Stake", amount: game.stake),
                .init(name: "Mult", amount: "\(game.multiplier.formatted())X")
            ])
            .padding(.vertical, 24)
            Spacer()
            
            Button("Collect points", action: viewModel.cashOut)
                .padding()
                .padding(.vertical, 8)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .disabled(!viewModel.canPlay)
        }
        .padding(32)
        .padding(.bottom, 8)
        .font(.custom("Carbon Bold",  size: UIFont.preferredFont(forTextStyle: .body).pointSize)
        )
        .textCase(.uppercase)
    }
}

struct GameDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameScene(viewModel: .init(container: .preview, id: Game.mockedData[0].id))
        }
        NavigationView {
            GameScene(viewModel: .init(container: .preview, id: Game.mockedData[0].id, game: .loaded(Game.mockedData[0])))
        }
    }
}

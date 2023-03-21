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
                gameInfoButton
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

    private var gameInfoButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if let game = viewModel.game.value {
                    NavigationLink(destination: GameInfoScene(viewModel: .init(container: viewModel.container, game: game))) {
                        Label("Game details", systemImage: "info.circle")
                    }
            }
        }
        
    }
    private var gameHeaderText: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(viewModel.header)
                .font(.carbon(forTextStyle: .title3))
                .textCase(.uppercase)
        }
    }
}

// MARK: - Loading Content

private extension GameScene {
    var notRequestedView: some View {
        Text("Oh no")
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
            
            
            if game.practice {
                PointsGrid(items: [
                    .init(name: "Bombs", amount: game.bombs.formatted()),
                    .init(name: "Mult", amount: "\(game.multiplier.formatted())X")
                ])
                .padding(.vertical, 24)
                .padding([.leading, .top, .trailing], 32)
            } else {
                PointsGrid(items: [
                    .init(name: "Next", amount: game.next?.formatted() ?? "-"),
                    .init("Stake", amount: game.stake),
                    .init(name: "Mult", amount: "\(game.multiplier.formatted())X")
                ])
                .padding(.vertical, 24)
                .padding([.leading, .top, .trailing], 32)
            }
            
            if game.practice {
                Text("This is only for practicing purpose.\nGood luck!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("grey"))
                    .padding(.horizontal, 4)
            }
            Spacer()
            
                
            if game.practice && !game.isActive  {
                Button("Try again", action: viewModel.createPracticeGame)
                        .secondaryButtonStyle()
                        .padding(.horizontal)
                    Button("Connect to wallet", action: {})
                        .primaryButtonStyle()
                        .padding()
            }
            
            if !game.practice {
                Button("Collect points", action: viewModel.cashOut)
                    .primaryButtonStyle()
                    .disabled(!viewModel.canPlay)
                    .padding()
            }
        }
        .font(.carbon())
        .textCase(.uppercase)
        .padding([.leading, .top, .trailing], 24)
    }
}

struct GameDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameScene(viewModel: .init(container: .preview))
        }
        
        NavigationView {
            GameScene(viewModel: .init(container: .preview, game: .loaded(Game.mockedData[0])))
        }
        
        NavigationView {
            GameScene(viewModel: .init(container: .preview, game: .loaded(Game.mockedData[1])))
        }
        
        NavigationView {
            GameScene(viewModel: .init(container: .preview, game: .loaded(Game.mockedData[2])))
        }
    }
}

//
//  HomeScene.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI
import Combine

struct HomeScene: View {
    @ObservedObject private(set) var viewModel: ViewModel

    let inspection = Inspection<Self>()

    var body: some View {
        NavigationView {
            content
                    .navigationBarTitle("Home")
                    .listStyle(.grouped)
                    .toolbar {
                        newGameButton
                    }
        }
                .navigationViewStyle(.stack)
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.games {
        case .notRequested: notRequestedView
        case let .isLoading(last, _): loadingView(last)
        case let .loaded(games): loadedView(games, showLoading: false)
        case let .failed(error): failedView(error)
        }
    }

    private var newGameButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(
                    destination: NewGameScene(viewModel: .init(container: viewModel.container)),
                    isActive: $viewModel.routingState.showNewGameScene
            ) {
                Label("Create game", systemImage: "plus")
            }
        }
    }
}

// MARK: - Loading Content

private extension HomeScene {
    var notRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadGames)
    }

    @ViewBuilder
    func loadingView(_ previouslyLoaded: [Game]?) -> some View {
        if let games = previouslyLoaded {
            loadedView(games, showLoading: true)
        } else {
            ActivityIndicatorView().padding()
        }
    }

    func failedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Content

private extension HomeScene {
    func loadedView(_ games: [Game], showLoading: Bool) -> some View {
        VStack {
            if showLoading {
                ActivityIndicatorView().padding()
            }
            if games.isEmpty {
                Text("No games yet")
            }
            List(games) { game in
                NavigationLink(
                        destination: self.gameView(game: game),
                        tag: game.id,
                        selection: $viewModel.routingState.gameId
                ) {
                    VStack(alignment: .leading) {
                        Text(game.id)
                                .font(.headline)
                        Text("Stake: \(game.stake)")
                                .font(.subheadline)
                    }
                }
// TODO: find out what's up .id(games.count)
            }
        }
    }


    func gameView(game: Game) -> some View {
        GameScene(viewModel: .init(container: viewModel.container, id: game.id, game: .loaded(game)))
    }
}

struct HomeScene_Previews: PreviewProvider {
    static var previews: some View {
        HomeScene(viewModel: .init(container: .preview))
    }
}

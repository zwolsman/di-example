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

    private var content: AnyView {
        switch viewModel.games {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last, _): return AnyView(loadingView(last))
        case let .loaded(games): return AnyView(loadedView(games, showLoading: false))
        case let .failed(error): return AnyView(failedView(error))
        }
    }

    private var newGameButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: NewGameScene(viewModel: .init(container: viewModel.container))) {
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

    func loadingView(_ previouslyLoaded: [Game]?) -> some View {
        if let games = previouslyLoaded {
            return AnyView(loadedView(games, showLoading: true))
        } else {
            return AnyView(ActivityIndicatorView().padding())
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
            } else {
                List(games) { game in
                    NavigationLink(destination: self.gamesView(game: game)) {
                        VStack(alignment: .leading) {
                            Text(game.id)
                                    .font(.headline)
                            Text("Stake: \(game.stake)")
                                    .font(.subheadline)
                        }
                    }
                }
                        .id(games.count)
            }
        }
    }

    func gamesView(game: Game) -> some View {
        GameScene(viewModel: .init(container: viewModel.container, id: game.id, game: .loaded(game)))
    }
}

struct HomeScene_Previews: PreviewProvider {
    static var previews: some View {
        HomeScene(viewModel: .init(container: .preview))
    }
}

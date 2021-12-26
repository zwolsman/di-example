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

            List {
                profileSection()
                if games.isEmpty {
                    VStack(alignment: .center) {
                        Text("You have not created any game yet. Start by tapping the button below.")
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        Button("Create game") {
                            viewModel.routingState.showNewGameScene.toggle()
                        }
                                .buttonStyle(.bordered)
                    }
                            .frame(maxWidth: .infinity)
                            .padding()
                } else {
                    gamesSection(games)
                }
            }
        }
    }

    func gamesSection(_ games: [Game]) -> some View {
        func gameView(game: Game) -> some View {
            GameScene(viewModel: .init(container: viewModel.container, id: game.id, game: .loaded(game)))
        }

        func gameRow(_ game: Game) -> some View {
            NavigationLink(
                    destination: gameView(game: game),
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
        }

        return Section {
            ForEach(games) { game in
                gameRow(game)
            }
        }
    }


    func profileSection() -> some View {
        func profileView() -> some View {
            ProfileScene(viewModel: .init(container: viewModel.container, profileType: .`self`))
        }

        func profileRow() -> some View {
            HStack {
                Circle()
                        .frame(maxWidth: 48, maxHeight: 48)
                        .aspectRatio(1.0, contentMode: .fill)
                        .padding(.trailing, 8)

                VStack(alignment: .leading) {
                    Text("Marvin Zwolsman")
                            .foregroundColor(.primary)
                    Text("You have \(1000.formatted()) points")
                            .foregroundColor(.secondary)
                }
            }
        }

        return Section {
            NavigationLink(destination: profileView()) {
                profileRow()
            }
        }
    }
}

struct HomeScene_Previews: PreviewProvider {
    static var previews: some View {
        HomeScene(viewModel: .init(container: .preview))
    }
}

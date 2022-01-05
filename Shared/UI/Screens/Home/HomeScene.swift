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
            content
                    .navigationBarTitle("Home")
                    .listStyle(.grouped)
                    .toolbar {
                        newGameButton
                    }
                    .navigationBarBackButtonHidden(true)
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    private var content: some View {
        List {
            profileContent

            gamesContent
        }
    }


    private var profileContent: some View {
        Section {
            switch viewModel.profile {
            case .notRequested: profileNotRequestedView
            case let .isLoading(last, _): loadingProfileView(last)
            case let .loaded(profile): loadedProfileView(profile, showLoading: false)
            case let .failed(error): profileFailedView(error)
            }
        }
    }

    @ViewBuilder
    private var gamesContent: some View {
        switch viewModel.games {
        case .notRequested: gamesNotRequestedView
        case let .isLoading(last, _): loadingGamesView(last)
        case let .loaded(games): loadedGamesView(games, showLoading: false)
        case let .failed(error): gamesFailedView(error)
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

// MARK: - Loading Games Content

private extension HomeScene {
    var gamesNotRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadGames)
    }

    @ViewBuilder
    func loadingGamesView(_ previouslyLoaded: [Game]?) -> some View {
        if let games = previouslyLoaded {
            loadedGamesView(games, showLoading: true)
        } else {
            ActivityIndicatorView().padding()
        }
    }

    func gamesFailedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Games Content

private extension HomeScene {
    @ViewBuilder
    func loadedGamesView(_ games: [Game], showLoading: Bool) -> some View {
        if showLoading {
            ActivityIndicatorView().padding()
        }

        if games.isEmpty {
            VStack(alignment: .center) {
                Text("No games to show right now.")
                        .foregroundColor(.secondary)
            }
                    .frame(maxWidth: .infinity)
                    .padding()
        } else {
            gamesSection(games)
        }
    }

    func gamesSection(_ games: [Game]) -> some View {
        func gameView(game: Game) -> some View {
            GameScene(viewModel: .init(container: viewModel.container, id: game.id, game: .loaded(game)))
        }

        func highlightButton(_ game: Game) -> some View {
            Button {
                print("highlight game")
            } label: {
                Label("Highlight", systemImage: "star")
            }
                    .tint(.yellow)
        }

        func deleteButton(_ game: Game) -> some View {
            Button(role: .destructive) {
                withAnimation {
                    viewModel.deleteGame(id: game.id)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }

        func archiveButton(_ game: Game) -> some View {
            Button {
                print("archive \(game.id)")
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
            .tint(.blue)
        }

        func gameRow(_ game: Game) -> some View {
            NavigationLink(
                    destination: gameView(game: game),
                    tag: game.id,
                    selection: $viewModel.routingState.gameId
            ) {
                GameRow(game: game)
            }
//                    .swipeActions(edge: .leading) {
//                        if game.state != .inGame {
//                            highlightButton(game)
//                        }
//                    }
                    .swipeActions(edge: .trailing) {
//                        archiveButton(game)
                        if game.state != .inGame {
                            deleteButton(game)
                        }
                    }
        }

        return Section {
            ForEach(games) { game in
                gameRow(game)
            }
        }
    }
}

// MARK: - Profile Loading Content

private extension HomeScene {
    var profileNotRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadProfile)
    }

    @ViewBuilder
    func loadingProfileView(_ previouslyLoaded: Profile?) -> some View {
        if let profile = previouslyLoaded {
            loadedProfileView(profile, showLoading: true)
        } else {
            ActivityIndicatorView().padding()
        }
    }

    func profileFailedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Profile Content

private extension HomeScene {
    func loadedProfileView(_ profile: Profile, showLoading: Bool) -> some View {
        func profileView() -> some View {
            ProfileScene(viewModel: .init(container: viewModel.container, profileType: .`self`, profile: .loaded(profile)))
        }

        func profileRow() -> some View {
            HStack {
                Circle()
                        .frame(maxWidth: 48, maxHeight: 48)
                        .aspectRatio(1.0, contentMode: .fill)
                        .padding(.trailing, 8)

                VStack(alignment: .leading) {
                    Text(profile.name)
                            .foregroundColor(.primary)
                    Text("You have \(profile.points.formatted()) points")
                            .foregroundColor(.secondary)
                }
            }
        }

        return NavigationLink(destination: profileView()) {
            profileRow()
        }
    }
}

struct HomeScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeScene(viewModel: .init(container: .preview))
        }
    }
}

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
    @Environment(\.injected) private var injected: DIContainer

    @State private(set) var games: Loadable<[Game]>
    @State private var routingState: Routing = .init()

    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.homeScene)
    }

    let inspection = Inspection<Self>()

    init(games: Loadable<[Game]> = .notRequested) {
        self._games = .init(initialValue: games)
    }

    var body: some View {
        NavigationView {
            content
        }
                .onReceive(routingUpdate) {
                    self.routingState = $0
                }
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }
    private var content: AnyView {
        switch games {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last, _): return AnyView(loadingView(last))
        case let .loaded(games): return AnyView(loadedView(games, showLoading: false))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Side Effects

private extension HomeScene {
    func reloadGames() {
        injected.interactors.gamesInteractor
                .load(games: $games)
    }
}

// MARK: - Loading Content

private extension HomeScene {
    var notRequestedView: some View {
        Text("").onAppear(perform: reloadGames)
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
            List(games) { game in
                NavigationLink(destination: self.gamesView(game: game)) {
                    Text(game.id)
                }
            }
                    .id(games.count)
        }
    }

    func gamesView(game: Game) -> some View {
        Text(game.id)
    }
}


// MARK: - Routing

extension HomeScene {
    struct Routing: Equatable {
        var gameDetails: String?
    }
}

// MARK: - State Updates

private extension HomeScene {

    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.homeScene)
    }
}

struct HomeScene_Previews: PreviewProvider {
    static var previews: some View {
        HomeScene()
    }
}

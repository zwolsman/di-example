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
                .navigationBarTitle("Game")
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    private var content: AnyView {
        switch viewModel.game {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(gameDetails): return AnyView(loadedView(gameDetails))
        case let .failed(error): return AnyView(failedView(error))
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
    func loadedView(_ game: Game) -> some View {
        Text("game tiles: here \(game.id)")
    }
}

struct GameDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        GameScene(viewModel: .init(container: .preview, id: Game.mockedData[0].id))
    }
}

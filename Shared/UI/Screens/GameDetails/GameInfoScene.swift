//
//  GameDetailsScene.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

struct GameInfoScene: View {
    @ObservedObject private(set) var viewModel: ViewModel

    let inspection = Inspection<Self>()

    var body: some View {
        content
                .navigationBarTitle("Game Info", displayMode: .inline)
                .listStyle(.grouped)
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.gameDetails {
        case .notRequested: notRequestedView
        case .isLoading: loadingView
        case let .loaded(gameDetails): loadedView(gameDetails)
        case let .failed(error): failedView(error)
        }
    }
}

// MARK: - Loading Content

private extension GameInfoScene {
    var notRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadGameDetails)
    }

    var loadingView: some View {
        VStack {
            ActivityIndicatorView()
            Button(action: {
                viewModel.gameDetails.cancelLoading()
            }, label: { Text("Cancel loading") })
        }
    }

    func failedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Content

private extension GameInfoScene {
    func loadedView(_ gameDetails: Game.Details) -> some View {
        List {
            basicInfo(details: gameDetails)
            secretInfo(details: gameDetails)
        }
    }

    private func basicInfo(details: Game.Details) -> some View {
        Section(header: Text("Info")) {
            DetailRow(left: Text("Initial stake"), right: Text("\(details.initialStake.formatted()) points"))
            DetailRow(left: Text("Stake"), right: Text("\(details.stake.formatted()) points"))
            DetailRow(left: Text("Multiplier"), right: Text("\(details.multiplier.formatted())x"))
            DetailRow(left: Text("Bombs"), right: Text("\(details.bombs)"))
            DetailRow(left: Text("Color"), right: ColorCell(color: details.color))
        }
    }

    private func secretInfo(details: Game.Details) -> some View {
        Section(header: Text("Game secret"), footer: secretFooter()) {
            Text(viewModel.showPlain ? viewModel.plain : viewModel.secret)
                    .multilineTextAlignment(.center)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.toggleSecret()
                    }
        }
    }

    func secretFooter() -> Text {
        Text("When a new game is started, three of the twenty-five tiles are chosen as mines. The three tiles (represented as numbers from 1 to 25,) coupled with a random string generated by the server are hashed using SHA256. The result of the hash function is shown to you before you make your first tile choice.")
    }
}


struct GameDetailsScene_Previews: PreviewProvider {
    static var previews: some View {
        GameInfoScene(viewModel: .init(container: .preview, gameId: Game.mockedData[0].id))
    }
}

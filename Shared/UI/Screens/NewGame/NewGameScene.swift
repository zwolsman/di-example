//
//  NewGameScene.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

struct NewGameScene: View {

    @ObservedObject private(set) var viewModel: ViewModel

    let inspection = Inspection<Self>()

    var body: some View {
        content
                .listStyle(.grouped)
                .navigationTitle("Create game")
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    private var content: AnyView {
        AnyView(loadedView())
    }
}

// MARK: - Displaying Content

private extension NewGameScene {
    func loadedView() -> some View {
        Form {
            Section {
                Picker("Color", selection: $viewModel.color) {
                    ForEach(Game.colors, id: \.self) {
                        ColorCell(color: $0)
                    }
                }

                Picker("Bombs", selection: $viewModel.bombs) {
                    ForEach(Bombs.allCases, id: \.self) { amount in
                        Text("\(amount.rawValue)").tag(amount)
                    }
                }
            }

            Section(footer: Text("You can adjust your stake in later versions")) {
                Text("Stake: 100")
            }

            Button("Create game") {
                viewModel.createGame()
            }
                    .disabled(!viewModel.canCreateGame)
        }
    }
}

struct NewGameScene_Previews: PreviewProvider {
    static var previews: some View {
        NewGameScene(viewModel: .init(container: .preview))
    }
}

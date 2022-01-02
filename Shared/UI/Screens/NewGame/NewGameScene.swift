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

    @ViewBuilder
    private var content: some View {
        loadedView()
    }
}

// MARK: - Displaying Content

private extension NewGameScene {
    func loadedView() -> some View {
        Form {
            Section {
                Picker("Color", selection: $viewModel.color) {
                    ForEach(Game.colors, content: ColorCell.init)
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

            Button("Create game", action: viewModel.createGame)
                    .disabled(!viewModel.canCreateGame)
        }
    }
}

extension Color: Identifiable {
    public var id: Color {
        self
    }
}

struct NewGameScene_Previews: PreviewProvider {
    static var previews: some View {
        NewGameScene(viewModel: .init(container: .preview))
    }
}

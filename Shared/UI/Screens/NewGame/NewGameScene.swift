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
        #if os(iOS)
                .listStyle(.grouped)
        #endif
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
private extension Button {
    func pointButtonStyle() -> some View {
        self
                .buttonStyle(.borderless)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                        RoundedRectangle(cornerRadius: 8)
                        #if os(iOS)
                            .fill(Color(uiColor: .systemGray5))
                        #elseif os(macOS)
                            .fill(Color(nsColor: .controlBackgroundColor))
                        #endif
                        )
    }
}

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

            Section(header: Text("Initial stake"), footer: Text("The minimal initial stake is a 100 points.")) {
                VStack {
                    TextField("Points", text: $viewModel.pointsText)
                    #if os(iOS)
                            .keyboardType(.numberPad)
                    #endif
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .padding()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {

                        Button("MIN", action: viewModel.setToMinPoints)
                                .pointButtonStyle()

                        Button("x2", action: viewModel.doublePoints)
                                .pointButtonStyle()

                        Button("MAX", action: viewModel.setToMaxPoints)
                                .pointButtonStyle()

                        ForEach([100, 1000, 10000, -100, -1000, -10000], id: \.self) { points in
                            let label = (points > 0 ? "+" : "") + points.formatted()
                            Button(label) {
                                viewModel.modifyPoints(points)
                            }
                                    .pointButtonStyle()

                        }
                    }
                }
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

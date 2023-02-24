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
                .preferredColorScheme(.dark)
                .font(.custom("Carbon Bold", size: 18))
                .textCase(.uppercase)
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
                                .fill(Color(.systemGray5)))
    }
}

private extension NewGameScene {
    func loadedView() -> some View {
        VStack {
            Spacer()
            Text("Your balance")
            Text("0xDEADCOFFEE")
                .foregroundColor(.accentColor)
                .textCase(.none)
            
            HStack(spacing: 4) {
                Text("1.2345")
                    .font(.custom("Carbon Bold", size: 56))
                Text("pts")
                    .foregroundColor(.accentColor)
            }
            Spacer()
            
            Section {
                VStack(alignment: .leading) {
                        Text("# Bombs")
                    
                    HStack {
                        TileButton(config: .init(id: 0))
                        TileButton(config: .init(id: 0))
                        TileButton(config: .init(id: 0))
                        TileButton(config: .init(id: 0))
                        TileButton(config: .init(id: 0))
                        
                        VStack {
                            Text("4")
                            Text("Hard")
                        }
                        .foregroundColor(Color("hard"))
                        
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .padding()
                    .background(Color("grey two"))
                    
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Initial stake")
                    Text("500")
                        .font(.custom("Carbon Bold", size: 32)) // TODO
                        .frame(maxWidth: .infinity)
                    HStack {
                        Button(action: {}) {
                            Text("Min")
                        }
                        .padding(16)
                        .border(Color("grey"))
                        .foregroundColor(Color("grey"))
                        
                        Button(action: {}) {
                            Text("100")
                        }
                        .padding(16)
                        .border(Color("grey"))
                        .foregroundColor(Color("grey"))
                        
                        Button(action: {}) {
                            Text("250")
                        }
                        .padding(16)
                        .border(Color("grey"))
                        .foregroundColor(Color("grey"))
                        
                        Button(action: {}) {
                            Text("500")
                        }
                        .padding(16)
                        .border(Color("grey"))
                        .foregroundColor(Color("grey"))
                        
                        Button(action: {}) {
                            Text("Max")
                        }
                        .padding(16)
                        .border(Color("grey"))
                        .foregroundColor(Color("grey"))
                    }
                }
            }
            .padding()
            Button(action: {}) {
                Text("Create Game")
                    .padding()
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .padding()
        }
        .padding()
//        Form {
//            Section {
//                Picker("Color", selection: $viewModel.color) {
//                    ForEach(Game.colors, content: ColorCell.init)
//                }
//
//                Picker("Bombs", selection: $viewModel.bombs) {
//                    ForEach(Bombs.allCases, id: \.self) { amount in
//                        Text("\(amount.rawValue)").tag(amount)
//                    }
//                }
//            }
//
//            Section(header: Text("Initial stake"), footer: Text("The minimal initial stake is a 100 points.")) {
//                VStack {
//                    TextField("Points", text: $viewModel.pointsText)
//                            .keyboardType(.numberPad)
//                            .multilineTextAlignment(.center)
//                            .lineLimit(1)
//                            .padding()
//
//                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
//
//                        Button("MIN", action: viewModel.setToMinPoints)
//                                .pointButtonStyle()
//
//                        Button("x2", action: viewModel.doublePoints)
//                                .pointButtonStyle()
//
//                        Button("MAX", action: viewModel.setToMaxPoints)
//                                .pointButtonStyle()
//
//                        ForEach([100, 1000, 10000, -100, -1000, -10000], id: \.self) { points in
//                            let label = (points > 0 ? "+" : "") + points.formatted()
//                            Button(label) {
//                                viewModel.modifyPoints(points)
//                            }
//                                    .pointButtonStyle()
//
//                        }
//                    }
//                }
//            }
//
//            Button("Create game", action: viewModel.createGame)
//                    .disabled(!viewModel.canCreateGame)
//        }
//                .alert(item: $viewModel.problem) {
//                    $0.alert
//                }
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

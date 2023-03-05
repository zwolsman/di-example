//
//  GameDetailsScene.swift
//  Checkpot
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI
import UIKit

struct GameInfoScene: View {
    @ObservedObject private(set) var viewModel: ViewModel
    let inspection = Inspection<Self>()

    var body: some View {
        content
                .navigationBarTitle("Game Info", displayMode: .inline)
                .toolbar {
                    headerText
                }
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    private var headerText: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Game info")
                .font(.carbon(forTextStyle: .title3))
                .textCase(.uppercase)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        loadedView(viewModel.game)
    }
}

// MARK: - Displaying Content

private extension GameInfoScene {
    func loadedView(_ game: Game) -> some View {
        VStack(alignment: .leading) {
            ZStack {
                Image("check background")
                    .renderingMode(.template)
                    .foregroundColor(.accentColor)
                    
                Image("check")
            }
            .padding(.bottom)
            
            Text("we believe that transparency, fairness, and trust are the foundation of a strong gaming community. That's why we're building a game where these values are at the forefront.\n\n" +
                 
                 "To ensure transparency and fairness, we use the SHA256 algorithm to hash three random tiles and a server-generated string.\n\n" +

                 "Before your first tile choice, we show you the hash result. After the game, reveal the secret by tapping the result. ")
            .padding(.bottom)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 4), spacing: 1) {
                Text("Initial")
                    .modifier(TableHeaderModifier())
                Text("Stake")
                    .modifier(TableHeaderModifier())
                Text("Mult")
                    .modifier(TableHeaderModifier())
                Text("Bombs")
                    .modifier(TableHeaderModifier())
                Text(viewModel.initialStake + "pts")
                    .modifier(TableCellModifier())
                Text(viewModel.stake + "pts")
                    .modifier(TableCellModifier())
                Text(viewModel.game.multiplier.formatted() + "x")
                    .modifier(TableCellModifier())
                Text("\(viewModel.game.bombs)")
                    .modifier(TableCellModifier())
            }.background(Color("grey"))
                .padding(1)
                .background(Color("grey"))
            
            Text("Game checksum")
                .padding(.top)
            HStack {
                Text(viewModel.secret)
                    .font(.carbon(size: 12))
                    .textCase(.none)
                    .lineLimit(2)
                    .foregroundColor(.black)
                    .padding()
                Spacer()
                    
                Button(action: viewModel.copyChecksum) {
                    Image(systemName: "square.on.square")
                        .renderingMode(.template)
                        .tint(.black)
                }
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: .infinity)
                .background(Color.accentColor)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .fixedSize(horizontal: false, vertical: true)
            
            
                Text("Game secret")
                    .padding(.top)
                HStack {
                    if let secret = game.plain {
                        Text(secret)
                            .font(.carbon(size: 12))
                            .textCase(.none)
                            .lineLimit(2)
                            .foregroundColor(.black)
                            .padding()
                        
                    } else {
                        Text("Finish the game to reveal the secret")
                            .font(.carbon(size: 12))
                            .lineLimit(2)
                            .foregroundColor(Color("grey"))
                            .padding()
                    }
                    Spacer()
                    Button(action: viewModel.copySecret) {
                        Image(systemName: "square.on.square")
                            .renderingMode(.template)
                            .foregroundColor(Color("grey"))
                    }
                    .padding()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxHeight: .infinity)
                    .background(Color.accentColor)
                    .disabled(game.plain == nil)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .font(.carbon())
        .textCase(.uppercase)
        .padding()
    }
}

struct GameDetailsScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameInfoScene(viewModel: .init(container: .preview, game: Game.mockedData[0]))
        }.preferredColorScheme(.dark)
        NavigationView {
            GameInfoScene(viewModel: .init(container: .preview, game: Game.mockedData[1]))
        }.preferredColorScheme(.dark)
    }
}

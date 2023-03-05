//
//  TileButton.swift
//  di-example
//
//  Created by Marvin Zwolsman on 01/01/2022.
//

import SwiftUI

struct TileButton: View {
    private let action: () -> Void
    private let tile: Tile?
    private let gameColor: Color

    init(config: Configuration) {
        action = config.action
        tile = config.tile
        gameColor = config.color
    }

    private var tileColor: Color {
        guard let tile = tile else {
            return Color("TileColor")
        }

        switch tile {
        case .bomb(true):
            return Color.black
        case .bomb(false):
            return Color.white
        case .loading:
            return Color("TileColor")
        case .points:
            return gameColor
        }
    }
    
    private var tileBackroundColor: Color {
        guard let tile else {
            return Color("grey two")
        }
        
        if case .bomb(true) = tile {
            return Color("BombTileColor")
        } else {
            return Color("grey two")
        }
    }
    
    private var isEnabled: Bool {
        tile == nil
    }
    
    @ViewBuilder
    private var foregroundImage: some View {
        switch tile {
        case .bomb(true):
            Image("bomb white")
                .resizable()
                .scaledToFit()
                .padding(8)
        case .bomb(false):
            Image("bomb black")
                .resizable()
                .scaledToFit()
                .padding(8)
        case .loading:
            ProgressView()
        default:
            Image("check")
                .resizable()
                .scaledToFit()
                .padding(8)
                
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image("check background")
                    .resizable()
                    .renderingMode(.template)
                    .tint(tileColor)
                    .scaledToFit()
                
                foregroundImage
            }
            .padding(12)
            .background(tileBackroundColor)
        }.allowsHitTesting(isEnabled)
    }
}

struct TileButton_Previews: PreviewProvider {
    private static let COLUMNS = Array(repeating: GridItem(.flexible()), count: 5)

    static var previews: some View {
        allTheButtons
                .preferredColorScheme(.light)

        allTheButtons
                .preferredColorScheme(.dark)
    }

    static var allTheButtons: some View {
        ScrollView {
            LazyVGrid(columns: COLUMNS) {
                TileButton(config: TileButton.Configuration(id: 0, tile: nil, color: .clear) {
                })
                TileButton(config: TileButton.Configuration(id: 0, tile: nil, color: .clear) {
                })
                TileButton(config: TileButton.Configuration(id: 0, tile: .bomb(revealedByUser: true), color: .clear) {
                })
                TileButton(config: TileButton.Configuration(id: 0, tile: .bomb(revealedByUser: false), color: .clear) {
                })
                TileButton(config: TileButton.Configuration(id: 0, tile: .loading, color: .clear) {
                })

                ForEach(Game.colors, id: \.self) { color in
                    ForEach(1...5, id: \.self) { expoonent in
                        let amount = Int(truncating: pow(10, expoonent) as NSNumber)
                        let config = TileButton.Configuration(id: 0, tile: .points(amount: amount), color: color) {
                        }
                        TileButton(config: config)
                    }
                }
            }.padding()
        }
    }
}

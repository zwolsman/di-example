//
//  TileButton.swift
//  di-example
//
//  Created by Marvin Zwolsman on 01/01/2022.
//

import SwiftUI

struct TileButton: View {
    private let action: () -> ()
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
            return Color("BombTileColor")
        case .bomb(false):
            return Color("TileColor")
        case .points(_):
            return gameColor
        }
    }

    private var textColor: Color {
        guard let tile = tile else {
            return .clear
        }

        switch tile {
        case .points(_):
            return .white
        case .bomb(true):
            return .white
        case .bomb(false):
            return .primary
        }
    }

    private var isDisabled: Bool {
        tile == nil
    }

    private var text: String {
        guard let tile = tile else {
            return ""
        }

        switch tile {
        case .bomb(_):
            return "BOMB"
        case let .points(amount):
            return amount.abbr()
        }
    }

    var body: some View {
        Button(action: action) {
            Rectangle()
                    .foregroundColor(tileColor)
                    .overlay {
                        Text(text)
                                .foregroundColor(textColor)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .allowsHitTesting(!isDisabled)
        }
    }
}

struct TileButton_Previews: PreviewProvider {
    private static let COLUMNS = Array(repeating: GridItem(.flexible()), count: 5)

    static var previews: some View {
        allTheButtons
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            
        allTheButtons
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
    
    static var allTheButtons: some View {
        ScrollView {
            LazyVGrid(columns: COLUMNS) {
                ForEach(Game.colors, id: \.self) { color in
                    ForEach(1...5, id: \.self) { i in
                        let amount = Int(truncating: pow(10, i) as NSNumber)
                        let config = TileButton.Configuration(id: 0, tile: .points(amount: amount), color: color) {
                        }
                        TileButton(config: config)
                    }
                }

                TileButton(config: TileButton.Configuration(id: 0, tile: .bomb(revealedByUser: true), color: .clear) {
                })
                TileButton(config: TileButton.Configuration(id: 0, tile: .bomb(revealedByUser: false), color: .clear) {
                })
                TileButton(config: TileButton.Configuration(id: 0, tile: nil, color: .clear) {
                })

            }.padding()
        }
    }
}

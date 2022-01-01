//
//  TileButton.swift
//  di-example
//
//  Created by Marvin Zwolsman on 01/01/2022.
//

import SwiftUI

struct TileButton: View {
    private let action: () -> ()
    private let state: Game.Tile
    private let gameColor: Color

    init(game: Game, id: Int, action: @escaping () -> ()) {
        self.action = action
        self.state = game.tiles[id] ?? .hidden
        self.gameColor = game.color
    }

    private var tileColor: Color {
        switch state {
        case .hidden, .bomb(_):
            return .secondary.opacity(0.2)
        case .revealed(_):
            return gameColor.opacity(0.2)
        }
    }

    private var textColor: Color {
        switch state {
        case .hidden:
            return .clear
        case .revealed(_):
            return gameColor
        case .bomb(true):
            return .primary
        case .bomb(false):
            return .secondary
        }
    }

    private var isDisabled: Bool {
        switch state {
        case .hidden:
            return false
        default:
            return true
        }
    }

    private var text: String {
        switch state {
        case .hidden:
            return ""
        case .bomb(_):
            return "BOMB"
        case let .revealed(points):
            return points.abbr()
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                        .foregroundColor(tileColor)
                        .cornerRadius(8)
                        .overlay {
                            Text(text)
                                    .foregroundColor(textColor)
                        }
            }
                    .aspectRatio(1, contentMode: .fit)
                    .allowsHitTesting(!isDisabled)
        }
    }
}

struct TileButton_Previews: PreviewProvider {

    static func createGame(color: Color, state: Game.Tile) -> Game {
        Game(id: "", tiles: [1: state], secret: "", stake: 0, bet: 0, next: 0, color: color, bombs: 0)
    }

    private static let COLUMNS = Array(repeating: GridItem(.flexible()), count: 5)

    static var previews: some View {
        ScrollView {
            LazyVGrid(columns: TileButton_Previews.COLUMNS) {
                ForEach(Game.colors, id: \.self) { color in

                    ForEach(1...5, id: \.self) { i in
                        let g = TileButton_Previews.createGame(color: color, state: .revealed(Int(truncating: pow(10, i) as NSNumber)))
                        TileButton(game: g, id: 1, action: {})
                    }
                }

                TileButton(game: Game.mockedData[0], id: 1, action: {})
                let bomb = TileButton_Previews.createGame(color: .clear, state: .bomb(true))

                TileButton(game: bomb, id: 1, action: {})

                let revealedBomb = TileButton_Previews.createGame(color: .clear, state: .bomb(false))

                TileButton(game: revealedBomb, id: 1, action: {})

            }.padding()
        }
    }
}

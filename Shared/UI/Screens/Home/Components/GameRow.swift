//
//  GameRow.swift
//  di-example
//
//  Created by Marvin Zwolsman on 01/01/2022.
//

import SwiftUI

struct GameRow: View {

    static let COLUMNS = Array(repeating: GridItem(.flexible(minimum: 5), spacing: 2), count: 5)
    let game: Game

    var body: some View {
        HStack {
            LazyVGrid(columns: GameRow.COLUMNS, spacing: 2) {
                ForEach(Game.TILE_RANGE, id: \.self) { tileId in
                    Tile(game: game, id: tileId)
                }
            }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 48, maxHeight: 48)

            VStack(alignment: .leading) {
                Text("Game \(game.id)")
                        .lineLimit(1)
                Text("Stake: \(game.stake)")
                        .foregroundColor(.secondary)
            }
                    .padding(.leading, 8)
        }

    }
}

extension GameRow {
    struct Tile: View {
        private let color: Color

        init(game: Game, id: Int) {
            guard let state = game.tiles[id] else {
                color = Color("TileColor")
                return
            }

            switch state {
            case .bomb(true):
                color = Color("BombTileColor")
            case .bomb(false):
                color = Color("TileColor")
            case .loading:
                color = Color("TileColor")
            case .points(_):
                color = game.color
            }
        }

        var body: some View {
            Rectangle()
                    .foregroundColor(color)
                    .aspectRatio(1.0, contentMode: .fill)
        }
    }
}

struct GameRow_Previews: PreviewProvider {
    static var previews: some View {
        GameRow(game: Game.mockedData[0])
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)

        GameRow(game: Game.mockedData[0])
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
    }
}

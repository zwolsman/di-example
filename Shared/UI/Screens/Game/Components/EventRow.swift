//
//  EventRow.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 24/04/2022.
//

import SwiftUI

struct EventRow: View {
    let tile: Tile
    let tileId: Int
    let gameColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            switch tile {
            case .points(let amount):
                Text("You found bits in tile \(tileId)!")
                    .fontWeight(.semibold)
                Text("+\(amount.formatted()) bits")
                    .foregroundColor(.secondary)
            case .bomb(revealedByUser: true):
                Text("You hit a bomb in tile \(tileId)!")
                    .fontWeight(.semibold)
                Text("and lost \(10_000.formatted()) bits")
                    .foregroundColor(.secondary)
            default:
                Text("TODO: \(String(describing: tile))")
            }
            
        }
        .padding(.leading, 12)
        .overlay(ribbon, alignment: .leading)
    }
    
    var ribbonColor: Color {
        switch tile {
        case .points(_):
            return gameColor
        case .bomb(_):
            return Color("BombTileColor")
        case .loading:
            return .secondary
        }
    }
    
    var ribbon: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .foregroundColor(ribbonColor)
            .frame(width: 4)
    }
}

struct EventRow_Previews: PreviewProvider {
    static var previews: some View {
        EventRow(tile: .points(amount: 10_000), tileId: 17, gameColor: .red)
            .previewLayout(.sizeThatFits)
        
        EventRow(tile: .bomb(revealedByUser: true), tileId: 11, gameColor: .red)
            .previewLayout(.sizeThatFits)
        
    }
}

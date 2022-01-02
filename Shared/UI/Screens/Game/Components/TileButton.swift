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
    
    init(config: Configuration) {
        self.action = config.action
        self.state = config.state
        self.gameColor = config.color
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
        ScrollView {
            LazyVGrid(columns: COLUMNS) {
                ForEach(Game.colors, id: \.self) { color in
                    ForEach(1...5, id: \.self) { i in
                        let points = Int(truncating: pow(10, i) as NSNumber)
                        let config = TileButton.Configuration(id: 0, state: .revealed(points), color: color) { }
                        TileButton(config: config)
                    }
                }
                
                TileButton(config: TileButton.Configuration(id: 0, state: .bomb(true), color: .clear) { })
                TileButton(config: TileButton.Configuration(id: 0, state: .bomb(false), color: .clear) { })
                TileButton(config: TileButton.Configuration(id: 0, state: .hidden, color: .clear) { })
                
            }.padding()
        }
    }
}

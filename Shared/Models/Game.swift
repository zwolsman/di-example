//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI

struct Game: Equatable, Identifiable {
    var id: String = UUID().uuidString

    var tiles: [Int:Tile] = [:]
    var secret: String
    var stake: Int
    var bet: Int
    var next: Int
    var color: Color
    var bombs: Int
}

extension Game {
    struct Details: Equatable {
        var initialStake: Int
        var stake: Int
        var bombs: Int
        var color: Color
        var secret: String
        var plain: String?
    }

    enum Tile: Equatable {
        case hidden
        case revealed(Int)
        case bomb(Bool)
    }
}

extension Game {
    static var colors = [
        Color.red,
        Color.orange,
        Color.yellow,
        Color.green,
        Color.mint,
        Color.teal,
        Color.cyan,
        Color.blue,
        Color.indigo,
        Color.purple,
        Color.pink,
        Color.brown,
    ]
    
    static let TILE_RANGE = 1...25
}

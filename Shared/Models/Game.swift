//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import SwiftUI

struct Game: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString

    var secret: String
    var stake: Int
    var bet: Int
    var next: Int
}

extension Game {
    struct Details: Codable, Equatable {
        let tiles: [Int]
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
}
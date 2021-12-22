//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

struct Game: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
}

extension Game {
    struct Details: Codable, Equatable {
        let tiles: [Int]
    }
}
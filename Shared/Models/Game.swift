//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

struct Game: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString

    var status: Bool
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
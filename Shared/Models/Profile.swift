//
// Created by Marvin Zwolsman on 26/12/2021.
//

import Foundation

struct Profile: Equatable {
    var name: String
    var points: Int
    var games: Int
    var totalEarnings: Int
    var link: String

    var highlights: [Game] = []
    var achievements: [String] = []
}

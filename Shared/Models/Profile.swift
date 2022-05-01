//
// Created by Marvin Zwolsman on 26/12/2021.
//

import Foundation

struct Profile: Equatable, Codable {
    var name: String
    var bits: Int
    var games: Int
    var bitsEarned: Int
    var link: String
}

struct ProfileWithTransactions: Equatable, Codable {
    var name: String
    var address: String
    var transactions: [Transaction]
}

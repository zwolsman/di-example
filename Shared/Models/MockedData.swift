//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

extension Game {
    static let mockedData = [
        Game(secret: "secret", stake: 100, bet: 100, next: 15, color: .red, bombs: 3)
    ]
}

extension Profile {
    static let mock = Profile(name: "Marvin Zwolsman", points: 1000, games: 56, totalEarnings: 65213)
}

//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

extension Game {
    static let mockedData = [
        Game(tiles: [:], secret: "secret", stake: 100, next: 15, multiplier: 1, color: .red, state: .inGame)
    ]
}

extension Profile {
    static let mock = Profile(name: "Marvin Zwolsman", points: 1000, games: 56, totalEarnings: 65213, link: "bombastic.dev/u/123456")
    static let mockWithHighlights = Profile(name: "Nicole Choi", points: 1000, games: 56, totalEarnings: 65213, link: "bombastic.dev/u/654321", highlights: [Game.mockedData[0]])
}

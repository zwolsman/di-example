//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

extension Game {
    static let mockedData = [
        Game(tiles: [:], secret: "secret", stake: 100, next: 15, multiplier: 1, color: .red, isActive: true, isCashedOut: false, initialBet: 100, bombs: 3)
    ]
}

extension Profile {
    static let mock = Profile(name: "Marvin Zwolsman", points: 1000, games: 56, totalEarnings: 65213, link: "bombastic.dev/u/123456")
    static let mockWithHighlights = Profile(name: "Nicole Choi", points: 1000, games: 56, totalEarnings: 65213, link: "bombastic.dev/u/654321")
}

extension Offer {
    static let mockMany = [
        Offer(offerId: 1, name: "SILVER", price: 2.0, points: 500, bonus: 0),
        Offer(offerId: 2, name: "GOLD", price: 10.0, points: 5002, bonus: 2),
        Offer(offerId: 3, name: "PLATINUM", price: 20, points: 10009, bonus: 9),
        Offer(offerId: 4, name: "DIAMOND", price: 50.0, points: 25074, bonus: 74),
    ]
    
    static let mock = mockMany[0]
}

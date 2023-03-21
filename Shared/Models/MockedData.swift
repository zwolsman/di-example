//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

// swiftlint:disable line_length
extension Game {
    static let mockedData = [
        Game(tiles: [1:.points(amount: 10), 10: .points(amount: 10)], secret: "f6fc84c9f21c24907d6bee6eec38cabab5fa9a7be8c4a7827fe9e56f245bd2d5", stake: 100, next: 15, multiplier: 1, color: .red, isActive: true, isCashedOut: false, initialBet: 100, bombs: 3),
        
        Game(tiles: [1:.points(amount: 10), 10: .points(amount: 10)], secret: "f6fc84c9f21c24907d6bee6eec38cabab5fa9a7be8c4a7827fe9e56f245bd2d5", stake: 100, next: 15, multiplier: 1, color: .red, isActive: false, isCashedOut: true, initialBet: 100, bombs: 3, plain: "25-18-15-Xzwg7Tq9WYPmzKHu"),
        
        Game(tiles: [:], secret: "f6fc84c9f21c24907d6bee6eec38cabab5fa9a7be8c4a7827fe9e56f245bd2d5", stake: 100, next: 0, multiplier: 1, color: .red, isActive: true, isCashedOut: false, initialBet: 0, bombs: 3, practice: true),
        Game(tiles: [1: .bomb(revealedByUser: true)], secret: "f6fc84c9f21c24907d6bee6eec38cabab5fa9a7be8c4a7827fe9e56f245bd2d5", stake: 100, next: 0, multiplier: 1, color: .red, isActive: false, isCashedOut: false, initialBet: 0, bombs: 3, plain: "1-18-15-Xzwg7Tq9WYPmzKHu", practice: true),
    ]
}

extension Profile {
    static let mock = Profile(name: "Marvin Zwolsman", points: 1000, games: 56, address: "0x17e237b7e8640a69a1b5452d1a7b1872b14444df")
    static let mockWithHighlights = Profile(name: "Babs", points: 1000, games: 56, address: "0xC0FFEE")
}

extension Offer {
    static let mockMany: [Offer] = [
        .init(id: "1", name: "SILVER", currency: .money, price: 2.0, reward: 500, bonus: 0),
        .init(id: "2", name: "GOLD", currency: .money, price: 10.0, reward: 5002, bonus: 2),
        .init(id: "3", name: "PLATINUM", currency: .money, price: 20, reward: 10009, bonus: 9),
        .init(id: "4", name: "DIAMOND", currency: .money, price: 50.0, reward: 25074, bonus: 74),
        .init(id: "5", name: "REGULAR", currency: .points, price: 1000, reward: 2)
    ]

    static let mockPoints = mockMany[0]
    static let mockPointsBonus = mockMany[1]
    static let mockPayOut = mockMany.last!
}

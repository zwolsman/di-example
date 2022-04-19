//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation

// swiftlint:disable line_length
extension Game {
    static let mockedData = [
        Game(tiles: [:], secret: "secret", stake: 100, next: 15, multiplier: 1, color: .red, isActive: true, isCashedOut: false, initialBet: 100, bombs: 3)
    ]
}

extension Profile {
    static let mock = Profile(name: "Marvin Zwolsman", points: 1000, games: 56, totalEarnings: 65213, link: "bombastic.dev/u/123456", balanceInEur: 50.0)
    static let mockWithHighlights = Profile(name: "Nicole Choi", points: 1000, games: 56, totalEarnings: 65213, link: "bombastic.dev/u/654321", balanceInEur: 100.0)
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

extension Date {
    static func from(_ year: Int, _ month: Int, _ day: Int) -> Date?
    {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: gregorianCalendar, year: year, month: month, day: day)
        return gregorianCalendar.date(from: dateComponents)
    }
}

extension Transaction {
    static let mockWithdraw = Transaction(type: .withdraw, amount: 15_000, timestamp: Date.from(2022, 4, 16)!)
    static let mockDeposit = Transaction(type: .deposit, amount: 15_000, timestamp: Date.from(2022, 4, 11)!)
}

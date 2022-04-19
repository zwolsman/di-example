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
    static let mock = Profile(name: "Marvin Zwolsman", bits: 1000, games: 56, bitsEarned: 65213, link: "bombastic.dev/u/123456")
    static let mockWithHighlights = Profile(name: "Nicole Choi", bits: 1000, games: 56, bitsEarned: 65213, link: "bombastic.dev/u/654321")
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

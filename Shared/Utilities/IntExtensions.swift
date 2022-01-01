//
// Created by Marvin Zwolsman on 01/01/2022.
//

import Foundation

extension Int {
    static func formatted(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value))!
    }

    func formatted() -> String {
        return Int.formatted(self)
    }

    func abbr() -> String {
        return Int.abbr(self)
    }

    static func abbr(_ value: Int) -> String {
        var num = Double(value)
        let sign = num < 0 ? "-" : ""

        num = fabs(num)

        if (num < 1000) {
            return "\(sign)\(Int.formatted(value))"
        }

        let exp = Int(log10(num) / 3)

        let units = ["K", "M", "G", "T", "P", "E"]

        let roundedNum = round(10 * num / pow(1000.0, Double(exp))) / 10

        return "\(sign)\(roundedNum.formatted())\(units[exp - 1])"
    }
}
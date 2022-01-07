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
    static func from(string: String) -> Int? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        return formatter.number(from: string) as? Int
    }

    func formatted() -> String {
        Int.formatted(self)
    }

    func abbr() -> String {
        Int.abbr(self)
    }

    static func abbr(_ value: Int) -> String {
        var num = Double(value)
        let sign = num < 0 ? "-" : ""

        num = fabs(num)

        if (num < 1000) {
            return "\(sign)\(value.formatted())"
        }

        let exp = Int(log10(num) / 3)

        let units = ["K", "M", "G", "T", "P", "E"]

        let roundedNum = round(10 * num / pow(1000.0, Double(exp))) / 10

        return "\(sign)\(roundedNum.formatted())\(units[exp - 1])"
    }
}

//
//  Offer.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation

struct Offer: Decodable, Identifiable {
    var id: String
    var name: String
    var currency: Currency
    var price: Double
    var reward: Double
    var bonus: Int?

    enum Currency: String, Decodable {
        case points = "POINTS"
        case money = "MONEY"
    }
}

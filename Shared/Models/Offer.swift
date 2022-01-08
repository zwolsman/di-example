//
//  Offer.swift
//  Bomastic
//
//  Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation

struct Offer: Identifiable, Decodable {
    var id: String {
        offerId
    }
    var offerId: String

    var name: String
    var price: Double
    var points: Int
    var bonus: Int
}
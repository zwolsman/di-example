//
//  Offer.swift
//  Bomastic
//
//  Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation

struct Offer: Identifiable, Decodable {
    var id: Int {
        offerId
    }
    var offerId: Int

    var name: String
    var price: Double
    var points: Int
    var bonus: Int
}
//
//  OfferRow.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 08/01/2022.
//
//

import SwiftUI

struct OfferRow: View {
    var offer: Offer

    var body: some View {
        HStack {
            VStack(alignment: .leading) {

                Text(offer.name.lowercased().capitalized)
                        .font(.title)

                switch offer.currency {
                case .money:
                    Text("\(offer.reward.formatted()) points")
                case .points:
                    Text("Add \(offer.reward.formatted(.currency(code: "EUR"))) to your profile balance")
                }

                if let bonus = offer.bonus, bonus > 0 {
                    Text("Receive \(bonus.formatted()) points for free!")
                }
            }
            Spacer()
            switch offer.currency {
            case .money:
                Text(offer.price.formatted(.currency(code: "EUR")))
            case .points:
                Text("\(offer.price.formatted()) points")
            }
        }.padding()
    }
}

struct OfferRow_Previews: PreviewProvider {
    static var previews: some View {
        OfferRow(offer: .mockPoints)
                .previewLayout(.sizeThatFits)
        OfferRow(offer: .mockPointsBonus)
                .previewLayout(.sizeThatFits)
        OfferRow(offer: .mockPayOut)
                .previewLayout(.sizeThatFits)
    }
}

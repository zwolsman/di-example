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
                Text("\(offer.points.formatted()) points")
                if offer.bonus > 0 {
                    Text("Receive \(offer.bonus.formatted()) points for free!")
                }
            }
            Spacer()
            Text(offer.price.formatted(.currency(code: "EUR")))
        }.padding()
    }
}

struct OfferRow_Previews: PreviewProvider {
    static var previews: some View {
        OfferRow(offer: .mockMany[1])
                .previewLayout(.sizeThatFits)
    }
}

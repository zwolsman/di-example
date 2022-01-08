//
//  StoreScene.swift
//  Bomastic
//
//  Created by Marvin Zwolsman on 08/01/2022.
//
//

import SwiftUI

struct StoreScene: View {
    @ObservedObject private(set) var viewModel: ViewModel

    let inspection = Inspection<Self>()

    var body: some View {
        content
                .navigationBarTitle("Store")
                .listStyle(.grouped)
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    @ViewBuilder
    var content: some View {
        switch viewModel.offers {
        case let .loaded(offers):
            loadedView(offers)
        default:
            Text("TODO")
        }
    }
    
    func loadedView(_ offers: [Offer]) -> some View {
        List {
            Section(footer: Text("The price you see here is artificial and will not be paid with real money. It does get substracted from your profile balance. Spend wisely.")) {
            ForEach(offers) { offer in
                Button(action: {}) {
                    OfferRow(offer: offer)
                }
            }
            }
            Section(header: Text("Pay out")) {
                Button(action: {}) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Regular")
                                .font(.title)
                            Text("Add €4.00 to your profile balance")
                        }
                        Spacer()
                        Text("1000 points")
                    }.padding()
                }
            }
        }
    }
}

struct StoreScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoreScene(viewModel: .init(container: .preview, offers: .loaded(Offer.mockMany)))
        }
    }
}

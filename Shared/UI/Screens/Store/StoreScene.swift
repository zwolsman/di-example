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
                .listStyle(.insetGrouped)
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    var content: some View {
        List {

        }
    }
}

struct StoreScene_Previews: PreviewProvider {
    static var previews: some View {
        StoreScene(viewModel: .init(container: .preview, offers: .loaded(Offer.mockMany)))
    }
}

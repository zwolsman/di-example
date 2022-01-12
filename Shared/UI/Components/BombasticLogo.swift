//
//  BombasticLogo.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 12/01/2022.
//
//

import SwiftUI

struct BombasticLogo: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Bomb")
                    .fontWeight(.bold)
            Text("astic")
                    .fontWeight(.light)
        }.font(.system(size: 42))
                .padding(.bottom, 16)
    }
}

struct BombasticLogo_Previews: PreviewProvider {
    static var previews: some View {
        BombasticLogo()
    }
}

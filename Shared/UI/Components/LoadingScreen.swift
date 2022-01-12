//
//  LoadingScreen.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 12/01/2022.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("Bomb")
                    .fontWeight(.bold)
                Text("astic")
                    .fontWeight(.light)
            }.font(.system(size: 42))
                .padding(.bottom, 16)
            ProgressView()
        }
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}

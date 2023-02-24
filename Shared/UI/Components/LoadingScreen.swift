//
//  LoadingScreen.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 12/01/2022.
//

import SwiftUI

struct LoadingScreen: View {
    var reason: String? = nil
    
    var body: some View {
        VStack {
            Image("william portret")
                .padding(.bottom)
            if let reason {
                Text(reason + "...")
                    .padding(.bottom)
            }
            ProgressView()
                .tint(.accentColor)
        }
        .preferredColorScheme(.dark)
        .font(.carbon())
        .textCase(.uppercase)
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen(reason: "Authenticating")
        LoadingScreen(reason: nil)
    }
}

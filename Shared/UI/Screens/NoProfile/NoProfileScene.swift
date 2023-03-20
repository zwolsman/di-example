//
//  NoProfileScene.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 17/03/2023.
//

import SwiftUI

struct NoProfileScene: View {
    var body: some View {
        VStack {
            Image("william portret error")
                .padding(.bottom)
                .padding(.top, 64)
           Text("Hark!")
                .padding(.bottom)
            Text("It seems like you didn't register your wallet to test checkpot.\nNo worries, we will invite you soon!")
                .foregroundColor(Color("grey"))
                .multilineTextAlignment(.center)
            Spacer()
            
            Button("Follow us on twitter", action: {open(url: "https://twitter.com/w_checkspeare")})
                .secondaryButtonStyle()
            Button("Buy your token on open sea", action: {open(url: "https://opensea.io/collection/william-checkspeare")})
                .primaryButtonStyle()
        }.padding(48)
        .preferredColorScheme(.dark)
        .font(.carbon())
        .textCase(.uppercase)
    }
}

struct NoProfileScene_Previews: PreviewProvider {
    static var previews: some View {
        NoProfileScene()
    }
}

extension NoProfileScene {
    func open(url: String) {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

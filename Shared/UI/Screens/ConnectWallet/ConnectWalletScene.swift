//
//  ConnectScene.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 24/02/2023.
//

import Foundation
import SwiftUI

struct ConnectWalletScene: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
            content
            .font(.carbon())
            .textCase(.uppercase)
        .navigationBarTitle("Connect wallet", displayMode: .inline)
        .toolbar {
            headerText
        }
        .navigationBarBackButtonHidden()
        
    }
    
    private var headerText: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Connect wallet")
                .font(.carbon(forTextStyle: .title3))
                .textCase(.uppercase)
        }
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            Spacer()
            Image("william portret")
            Image("signature")
                .padding()
            Spacer()
            Button(action: {}) {
                HStack {
                    Image("metamask")
                    Text("Metamask")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .padding()
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .background(.white)
            Text("By proceeding, you agree to our\nPrivacy Policy & Terms of Service")
                .foregroundColor(Color("grey"))
                .padding(.top)
        }.padding()
    }
}

class ConnectWalletScene_Previews :PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConnectWalletScene(viewModel: .init(container: .preview))
                .preferredColorScheme(.dark)
        }
    }
}

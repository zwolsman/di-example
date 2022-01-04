//
//  SignInScene.swift
//  di-example
//
//  Created by Marvin Zwolsman on 04/01/2022.
//

import SwiftUI
import AuthenticationServices

struct SignInScene: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("Bomb")
                        .fontWeight(.bold)
                Text("astic")
                        .fontWeight(.light)
            }.font(.system(size: 42))
                    .padding(.bottom, 16)

            Text("The more greens you find on the 5x5 grid, the higher your multiplier. Try not to hit any mines or your game will end!")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

            SignInWithAppleButton(.signIn, onRequest: viewModel.setupSignInRequest(request:), onCompletion: viewModel.onCompletion(result:))
                    .frame(width: 280, height: 60)
                    .padding()
            Spacer()
        }.padding()
    }
}

struct SignInScene_Previews: PreviewProvider {
    static var previews: some View {
        SignInScene(viewModel: .init(container: .preview))
    }
}

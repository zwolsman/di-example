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
        content
    }

    @ViewBuilder
    var content: some View {
        switch viewModel.authenticated {
        case .notRequested, .failed, .loaded(false):
            notRequestedView
        case .isLoading:
            LoadingScreen()
        default:
            Text("TODO")
        }
    }
}

extension SignInScene {
    var notRequestedView: some View {
        VStack {
            BombasticLogo()
                    .id("logo")

            Text("The more greens you find on the 5x5 grid, the higher your multiplier. Try not to hit any mines or your game will end!")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()

            SignInWithAppleButton(.signIn,
                    onRequest: viewModel.setupSignInRequest(request:),
                    onCompletion: viewModel.onCompletion(result:))
                    .frame(width: 280, height: 40)
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

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
        NavigationView {
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
                
                SignInWithAppleButton(.signIn, onRequest: viewModel.setupSignInReqtuest(request:), onCompletion: viewModel.onCompletion(result:))
                    .frame(width: 210, height: 30)
                    .padding()
                
                NavigationLink(isActive: $viewModel.authenticated, destination: homeScene, label: EmptyView.init)
                    .hidden()
                Spacer()
            }.padding()
        }
    }
    
    private func homeScene() -> HomeScene {
        return HomeScene(viewModel: .init(container: viewModel.container))
    }
}

struct SignInScene_Previews: PreviewProvider {
    static var previews: some View {
        SignInScene(viewModel: .init(container: .preview))
    }
}

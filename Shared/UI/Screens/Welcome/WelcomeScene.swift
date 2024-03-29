//
//  WelcomeScene.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 04/01/2022.
//

import SwiftUI
import AuthenticationServices

struct WelcomeScene: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        content
    }
    
    @ViewBuilder
    var content: some View {
        ZStack {
            VStack {
                Spacer()
                Image("william")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
            }.ignoresSafeArea()
            VStack {
                Image("check home")
                    .padding()
                
                Text("To burn, or not to burn")
                    .font(.carbon(forTextStyle: .title1))
                
                Text("By william checkspeare")
                    .font(.carbon(forTextStyle: .subheadline))
                
                Spacer()

                NavigationLink(destination: ConnectWalletScene(viewModel: .init(container: viewModel.container, authenticated: viewModel.authenticated))) {
                    Text("Connect wallet")
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(.black)
                }
                
                Button(action: viewModel.createPracticeGame) {
                    Text("Quick play")
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(.white)
                }
                
                if let game = viewModel.routingState.practiceGame {
                    NavigationLink(destination: GameScene(viewModel: .init(container: viewModel.container, game: .loaded(game))), isActive: $viewModel.isInGame) {
                        EmptyView()
                    }
                }
                
            }
            .foregroundColor(.black)
            .padding(16)
            .font(.carbon())
            .textCase(.uppercase)
        }
        .background(
            Image("bg-gradient")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
    }
}


struct WelcomeScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WelcomeScene(viewModel: .init(container: .preview))
                .preferredColorScheme(.dark)
        }
    }
}

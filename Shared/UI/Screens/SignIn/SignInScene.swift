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
                Button {
                } label: {
                    Text("Let's start")
                        .padding(8)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(.black)
            }
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

struct SignInScene_Previews: PreviewProvider {
    static var previews: some View {
        SignInScene(viewModel: .init(container: .preview))
    }
}

//
//  ContentView.swift
//  Shared
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI
import Combine
import AuthenticationServices

// MARK: - View

struct ContentView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    var body: some View {
        if viewModel.isRunningTests {
            Text("Running unit tests")
        } else {
            NavigationView {
                if viewModel.isVerifying {
                    LoadingScreen()
                } else if viewModel.authenticated {
                    homeScene
                } else {
                    signInScene
                }
            }
            .onAppear(perform: viewModel.validateUser)
            .modifier(RootViewAppearance(viewModel: .init(container: viewModel.container)))
        }
        
    }
    
    private var homeScene: some View {
        HomeScene(viewModel: .init(container: viewModel.container))
    }
    private var signInScene: some View {
        SignInScene(viewModel: .init(container: viewModel.container))
    }
}

// MARK: - ViewModel

extension ContentView {
    class ViewModel: ObservableObject {
        // State
        @Published var authenticated: Bool = false
        @Published var isVerifying: Bool = true
        
        // Misc
        let container: DIContainer
        let isRunningTests: Bool
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests) {
            self.container = container
            self.isRunningTests = isRunningTests
            let appState = container.appState
            
            cancelBag.collect {
                appState.updates(for: \.userData.authenticated)
                    .weakAssign(to: \.authenticated, on: self)
            }
        }
        
        func validateUser() {
            guard let userId = UserDefaults.standard.string(forKey: "user.id"),
                  let accessToken = UserDefaults.standard.string(forKey: "access_token") else {
                      UserDefaults.standard.removeObject(forKey: "user.id")
                      UserDefaults.standard.removeObject(forKey: "access_token")
                      print("could not recover user")
                      authenticated = false
                      finishVerification()
                      return
                  }
            
            container
                .services
                .authService
                .verify(token: accessToken)
                .replaceError(with: false)
                .sink { [weak self] isValid in
                    if isValid {
                        self?.checkCredentialState(forUserID: userId)
                    } else {
                        self?.authenticated = false
                        self?.finishVerification()
                    }
                }
                .store(in: cancelBag)
           
        }
        
        private func checkCredentialState(forUserID userId: String) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userId) { [weak self] (credentialState, error) in
                guard error == nil else {
                    print(error!)
                    self?.authenticated = false
                    self?.finishVerification()
                    return
                }
                
                if credentialState == .authorized {
                    self?.authenticated = true
                    self?.finishVerification()
                }
            }
        }
        
        private func finishVerification() {
            isVerifying = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel(container: .preview))
    }
}

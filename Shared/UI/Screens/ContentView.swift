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
                if viewModel.authenticated {
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
        @Published var authenticated: Bool

        // Misc
        let container: DIContainer
        let isRunningTests: Bool
        private var cancelBag = CancelBag()

        init(container: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests) {
            self.container = container
            self.isRunningTests = isRunningTests
            let appState = container.appState
            _authenticated = .init(initialValue: false)

            cancelBag.collect {
                appState.map(\.userData.authenticated)
                        .removeDuplicates()
                        .weakAssign(to: \.authenticated, on: self)
            }
        }

        func validateUser() {
            guard let userId = UserDefaults.standard.string(forKey: "user.id"),
                  let _ = UserDefaults.standard.string(forKey: "access_token") else {
                print("could not recover user")
                authenticated = false
                return
            }

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userId) { [weak self] (credentialState, error) in
                guard error == nil else {
                    print(error!)
                    self?.authenticated = false
                    return
                }

                if credentialState == .authorized {
                    print("user still valid")
                    self?.authenticated = true
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel(container: .preview))
    }
}

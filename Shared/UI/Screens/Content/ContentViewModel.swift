//
// Created by Marvin Zwolsman on 12/01/2022.
//

import Foundation
import AuthenticationServices

// MARK: - ViewModel

extension ContentView {
    class ViewModel: ObservableObject {
        // State
        @Published var authenticated: Loadable<Bool>

        // Misc
        let container: DIContainer
        let isRunningTests: Bool
        private var cancelBag = CancelBag()

        init(container: DIContainer,
             authenticated: Loadable<Bool> = .notRequested,
             isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests) {
            print("content view created")
            self.container = container
            self.isRunningTests = isRunningTests
            let appState = container.appState
            _authenticated = .init(initialValue: authenticated)

            cancelBag.collect {
                appState.updates(for: \.userData.authenticated)
                        .weakAssign(to: \.authenticated, on: self)
            }
        }

        func loadAuthenticationState() {
            container.appState[\.userData.authenticated].setIsLoading(cancelBag: cancelBag)

            func resetUserDefaults() {
                UserDefaults.standard.removeObject(forKey: "user.id")
                UserDefaults.standard.removeObject(forKey: "access_token")
            }

            guard let userId = UserDefaults.standard.string(forKey: "user.id"),
                  let accessToken = UserDefaults.standard.string(forKey: "access_token") else {
                resetUserDefaults()
                print("could not recover user")
                container.appState[\.userData.authenticated] = .loaded(false)
                return
            }

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userId) { [weak self] (credentialState, error) in
                guard error == nil else {
                    print(error!)
                    resetUserDefaults()
                    self?.container.appState[\.userData.authenticated] = .loaded(false)
                    return
                }

                if credentialState == .authorized {
                    self?.verifyAccessToken(accessToken)
                } else {
                    resetUserDefaults()
                    self?.container.appState[\.userData.authenticated] = .loaded(false)
                }
            }

        }

        private func verifyAccessToken(_ token: String) {
            weak var weakAppState = container.appState
            container
                    .services
                    .authService
                    .verify(token: token)
                    .sinkToLoadable {
                        weakAppState?[\.userData.authenticated] = $0
                    }
                    .store(in: cancelBag)
        }

    }
}

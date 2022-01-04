//
//  SignInSceneViewModel.swift
//  di-example
//
//  Created by Marvin Zwolsman on 04/01/2022.
//

import Foundation
import AuthenticationServices

// MARK: - Routing

extension SignInScene {
    struct Routing: Equatable {

    }
}

extension SignInScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var authenticated: Bool = false

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.signInScene)

            cancelBag.collect {
                $routingState
                        .removeDuplicates()
                        .sink {
                            appState[\.routing.signInScene] = $0
                        }
                appState.map(\.routing.signInScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)

                appState.map(\.userData.authenticated)
                        .removeDuplicates()
                        .weakAssign(to: \.authenticated, on: self)
            }
        }

        func setupSignInRequest(request: ASAuthorizationAppleIDRequest) {
            request.requestedScopes = [.fullName, .email]
        }

        func onCompletion(result: Result<ASAuthorization, Error>) {
            switch result {
            case .success(let authorization):
                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    let userId = appleIDCredential.user
                    let identityToken = appleIDCredential.identityToken?.base64EncodedString() ?? ""
                    let authCode = appleIDCredential.authorizationCode?.base64EncodedString() ?? ""
                    let fullName = appleIDCredential.fullName

                    print(userId)
                    print(identityToken)
                    print(authCode)



                    var oldProfile: Profile? = nil
                    let data = UserDefaults.standard.data(forKey: "user.json")
                    if data != nil {
                        oldProfile = try? JSONDecoder().decode(Profile.self, from: data!)
                    }
                    let name = fullName?.givenName ?? oldProfile?.name ?? "Unknown user"
                    let userProfile = Profile(name: name,
                            points: oldProfile?.points ?? 1000,
                            games: oldProfile?.games ?? 0,
                            totalEarnings: oldProfile?.totalEarnings ?? 0,
                            link: "https://bombastic.dev/u/id"
                    )
                    UserDefaults.standard.set(userId, forKey: "user.id")

                    container.appState.bulkUpdate { state in
                        state.userData.profile = .loaded(userProfile)
                        state.userData.authenticated = true
                    }

                    print("Authenticated user \(userProfile)!")
                }
                break
            case .failure(let error):
                container.appState[\.userData.authenticated] = false
                print(error)
                break
            }
        }
    }
}

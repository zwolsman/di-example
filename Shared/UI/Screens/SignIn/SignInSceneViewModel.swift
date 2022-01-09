//
//  SignInSceneViewModel.swift
//  di-example
//
//  Created by Marvin Zwolsman on 04/01/2022.
//

import Foundation
import Combine
import Moya
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
                appState.updates(for: \.routing.signInScene)
                        .weakAssign(to: \.routingState, on: self)

                appState.updates(for: \.userData.authenticated)
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
                    let idToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
                    let authCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)!
                    let fullName = appleIDCredential.fullName

                    if let fullName = fullName?.formatted(.name(style: .long)), let email = appleIDCredential.email {
                        print("registering user. name: \(fullName), email: \(email)")
                        container
                                .services
                                .authService
                                .register(email: email, fullName: fullName, authCode: authCode, identityToken: idToken)
                                .map {
                                    (userId, $0)
                                }
                                .sinkToResult(onAuthResponse)
                                .store(in: cancelBag)
                    } else {
                        container
                                .services
                                .authService
                                .verify(authCode: authCode, identityToken: idToken)
                                .map {
                                    (userId, $0)
                                }
                                .sinkToResult(onAuthResponse)
                                .store(in: cancelBag)
                    }
                }
            case .failure(let error):
                container.appState[\.userData.authenticated] = false
                print(error)
            }
        }

        private func onAuthResponse(result: Result<(userId: String, accessToken: String), MoyaError>) {
            switch result {
            case let .success((userId, accessToken)):
                onAccessToken(userId: userId, accessToken: accessToken)
            case let .failure(error):
                onError(error)
            }
        }

        private func onError(_ error: MoyaError) {
            print("received error!")
            print(error)
        }

        private func onAccessToken(userId: String, accessToken: String) {
            print("Received access token from api")
            UserDefaults.standard.set(accessToken, forKey: "access_token")
            UserDefaults.standard.set(userId, forKey: "user.id")
            container.appState[\.userData.authenticated] = true
        }
    }

}

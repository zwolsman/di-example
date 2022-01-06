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
                    let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
                    let authCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)!
                    let fullName = appleIDCredential.fullName

                    print(userId)
                    print(identityToken)
                    print(authCode)

                    if let fullName = fullName?.formatted(.name(style: .short)), let email = appleIDCredential.email {
                        print("registering user. name: \(fullName), email: \(email)")
                        container
                                .services
                                .authService
                                .register(email: email, fullName: fullName, authCode: authCode, identityToken: identityToken)
                                .sink(receiveCompletion: onError, receiveValue: onAccessToken)
                                .store(in: cancelBag)
                    } else {
                        container
                                .services
                        .authService
                                .verify(authCode: authCode, identityToken: identityToken)
                    }
                }
                break
            case .failure(let error):
                container.appState[\.userData.authenticated] = false
                print(error)
                break
            }
        }


        private func onError(cpl: Subscribers.Completion<MoyaError>) {
            guard let err = cpl.error else {
                return
            }

            print("received error!")
            print(err)
        }

        private func onAccessToken(accessToken: String) {
            print("Received access token from api")
            UserDefaults.standard.set(accessToken, forKey: "access_token")
            container.appState[\.userData.authenticated] = true
        }
    }


}

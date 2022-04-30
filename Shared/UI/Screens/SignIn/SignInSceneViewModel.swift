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
        @Published var authenticated: Loadable<Bool>

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer, authenticated: Loadable<Bool> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.signInScene)
            _authenticated = .init(initialValue: authenticated)

            cancelBag.collect {
                $routingState
                        .removeDuplicates()
                        .sink {
                            appState[\.routing.signInScene] = $0
                        }

                $authenticated
                        .removeDuplicates()
                        .sink {
                            appState[\.userData.authenticated] = $0
                        }

                appState.updates(for: \.routing.signInScene)
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        func setupSignInRequest(request: ASAuthorizationAppleIDRequest) {
            request.requestedScopes = [.fullName]
        }

        func onCompletion(result: Result<ASAuthorization, Error>) {
            // Start showing the loading screen
            authenticated.setIsLoading(cancelBag: cancelBag)

            switch result {
            case let .success(authorization):
                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    let userId = appleIDCredential.user
                    let idToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
                    let authCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)!
                    let fullName = appleIDCredential.fullName

                    let publisher: AnyPublisher<String, MoyaError>
                    if let fullName = fullName?.formatted(.name(style: .long)) {
                        print("registering user. name: \(fullName)")
                        publisher = container
                                .services
                                .authService
                                .register(fullName: fullName, authCode: authCode, identityToken: idToken)
                    } else {
                        publisher = container
                                .services
                                .authService
                                .verify(authCode: authCode, identityToken: idToken)

                    }

                    publisher.sinkToLoadable { [self] in
                                let result = $0.map { accessToken -> Bool in
                                    self.onAccessToken(userId: userId, accessToken: accessToken)
                                    return true
                                }
                                authenticated = result
                            }
                            .store(in: cancelBag)
                }
            case let .failure(error):
                authenticated = .failed(error)
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
            print(error)
            authenticated = .failed(error)
            print("received error!")
        }

        private func onAccessToken(userId: String, accessToken: String) {
            print("Received access token from api")
            UserDefaults.standard.set(accessToken, forKey: "access_token")
            UserDefaults.standard.set(userId, forKey: "user.id")
            authenticated = .loaded(true)
        }
    }

}

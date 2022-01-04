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
        
        func setupSignInReqtuest(request: ASAuthorizationAppleIDRequest) {
            
        }
        
        func onCompletion(result: Result<ASAuthorization, Error>) {
            switch result {
            case .success(let authorization):
                //Handle autorization
                break
            case .failure(let error):
                authenticated = false
                print(error)
                break
            }
        }
    }
}

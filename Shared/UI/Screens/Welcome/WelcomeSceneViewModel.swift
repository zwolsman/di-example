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

extension WelcomeScene {
    struct Routing: Equatable {
        var practiceGame: Game? = nil
    }
}

extension WelcomeScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var authenticated: Loadable<Bool>
        @Published var isInGame: Bool = false
        @Published var newGame: Loadable<Game> = .notRequested

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer, authenticated: Loadable<Bool> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.welcomeScene)
            _authenticated = .init(initialValue: authenticated)

            cancelBag.collect {
                $routingState
                        .removeDuplicates()
                        .sink {
                            appState[\.routing.welcomeScene] = $0
                        }
                
                $newGame
                    .sink {
                        appState[\.routing.welcomeScene.practiceGame] = $0.value
                    }

                appState.updates(for: \.routing.welcomeScene)
                        .weakAssign(to: \.routingState, on: self)
                appState.updates(for: \.userData.authenticated)
                        .weakAssign(to: \.authenticated, on: self)
            }
        }
        
        func createPracticeGame() {
            isInGame = true
            container
                .services
                .practiceService
                .create(game: loadableSubject(\.newGame))
        }
    }

}

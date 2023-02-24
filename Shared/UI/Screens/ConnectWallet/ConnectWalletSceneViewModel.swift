//
//  ConnectSceneViewModel.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 24/02/2023.
//

import Foundation

// MARK: - Routing

extension ConnectWalletScene {
    struct Routing: Equatable {

    }
}

extension ConnectWalletScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.connectWalletScene)

            cancelBag.collect {
                $routingState
                        .removeDuplicates()
                        .sink {
                            appState[\.routing.connectWalletScene] = $0
                        }

               
                appState.updates(for: \.routing.connectWalletScene)
                        .weakAssign(to: \.routingState, on: self)
            }
        }
    }
}

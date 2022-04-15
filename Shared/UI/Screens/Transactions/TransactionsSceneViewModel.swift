//
//  TransactionsSceneViewModel.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 15/04/2022.
//

import Foundation

// MARK: - Routing

extension TransactionsScene {
    struct Routing: Equatable {

    }
}

extension TransactionsScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.transactionsScene)

            cancelBag.collect {
                $routingState
                        .removeDuplicates()
                        .sink {
                            appState[\.routing.transactionsScene] = $0
                        }

                appState.updates(for: \.routing.transactionsScene)
                        .weakAssign(to: \.routingState, on: self)
            }
        }
    }
}

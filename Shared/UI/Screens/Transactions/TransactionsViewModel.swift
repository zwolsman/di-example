//
//  TransactionsViewModel.swift
//  Bombastic (iOS)
//
//  Created by Marvin Zwolsman on 19/04/2022.
//

import Foundation

// MARK: - Routing

extension TransactionsScene {
    struct Routing: Equatable {

    }
}

// MARK: - ViewModel

extension TransactionsScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var profile: Loadable<ProfileWithTransactions>
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer, profile: Loadable<ProfileWithTransactions> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.transactionsScene)
            _profile = .init(initialValue: profile)

            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.transactionsScene] = $0
                        }
                appState.map(\.routing.transactionsScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        // MARK: - Side Effects

        func loadTransactions() {
            container.services.profileService.loadProfileWithTransactions(profileWithTransaction: loadableSubject(\.profile))
        }
    }
}

//
// Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation
import SwiftUI

// MARK: - Routing

extension StoreScene {
    struct Routing: Equatable {

    }
}

extension StoreScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var offers: Loadable<[Offer]>
        @Published var profile: Loadable<Profile> = .notRequested

        var canPayOut: Bool {
            guard let currentPoints = container.appState[\.userData.profile].value?.points else {
                return false
            }
            return currentPoints >= 1000
        }

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()

        init(container: DIContainer, offers: Loadable<[Offer]> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.storeScene)
            _offers = .init(initialValue: offers)

            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.storeScene] = $0
                        }
                appState.map(\.routing.storeScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        // MARK: - Side effects

        func loadOffers() {
            container.services.storeService.loadOffers(offers: loadableSubject(\.offers))
        }

        func purchase(offer: Offer) {
            let profileSubject = loadableSubject(\.profile).onSet {
                guard case .loaded = $0 else {
                    return
                }
                self.purchasedOffer()
            }

            container.services.storeService.purchase(offer: offer, profile: profileSubject)
        }

        func isDisabled(offer: Offer) -> Bool {
            switch offer.currency {
            case .money:
                return false
            case .points:
                guard let balance = container.appState[\.userData.profile].value?.points else {
                    return true
                }
                return offer.price > Double(balance)
            }
        }

        private func purchasedOffer() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            container.appState.bulkUpdate { state in
                state.routing.homeScene.showProfileScene = false
                state.userData.profile = profile
            }
        }
    }
}

//
// Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation

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

        //MARK: - Side effects

        func loadOffers() {
            container.services.storeService.loadOffers(offers: loadableSubject(\.offers))
        }
    }
}
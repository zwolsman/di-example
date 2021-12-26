//
// Created by Marvin Zwolsman on 26/12/2021.
//

import Foundation

// MARK: - Routing

extension ProfileScene {
    struct Routing: Equatable {

    }
}

// MARK: - ViewModel

extension ProfileScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var profile: Loadable<Profile>

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        let profileType: ProfileType

        init(container: DIContainer, profileType: ProfileType, profile: Loadable<Profile> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.profileScene)
            _profile = .init(initialValue: profile)
            self.profileType = profileType

            cancelBag.collect {
                $routingState
                        .sink {
                            appState[\.routing.profileScene] = $0
                        }
                appState.map(\.routing.profileScene)
                        .removeDuplicates()
                        .weakAssign(to: \.routingState, on: self)
            }
        }

        // MARK: - Side Effects

        func loadProfile() {

        }
    }
}

extension ProfileScene {
    enum ProfileType {
        case `self`
        case other(String)
    }
}
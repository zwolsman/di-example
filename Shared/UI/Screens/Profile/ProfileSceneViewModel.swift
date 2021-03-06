//
// Created by Marvin Zwolsman on 26/12/2021.
//

import Foundation
import SwiftUI

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
            if let profileId = profileType.profileId {
                container.services.profileService.loadProfile(id: profileId, profile: loadableSubject(\.profile))
            } else {
                container.services.profileService.loadMe()
            }
        }

        func shareProfile() {
//            guard  let link = profile.value?.link, let data = URL(string: link) else {
//                return
//            }
//            let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
//            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        }
    }
}

extension ProfileScene {
    enum ProfileType: Equatable {
        case own
        case other(String)

        var profileId: String? {
            switch self {
            case .own:
                return nil
            case let .other(profileId):
                return profileId
            }
        }
    }
}

//
// Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation
import Combine

protocol ProfileService {
    func loadProfile(token: String)
}

class LocalProfileService: ProfileService {
    let appState: Store<AppState>

    init(appState: Store<AppState>) {
        self.appState = appState
    }

    func loadProfile(token: String) {
        let cancelBag = CancelBag()
        appState[\.userData.profile].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        guard let profileJSON = UserDefaults.standard.data(forKey: "user.json") else {
            appState[\.userData.profile] = .failed(ProfileError.noProfileFoundError)
            return
        }

        guard let profile = try? JSONDecoder().decode(Profile.self, from: profileJSON) else {
            appState[\.userData.profile] = .failed(ProfileError.profileDecodeError)
            return
        }

        Just(profile)
                .sinkToLoadable {
                    weakAppState?[\.userData.profile] = $0
                }
                .store(in: cancelBag)
    }

    enum ProfileError: Error {
        case noProfileFoundError
        case profileDecodeError
    }


}

struct StubProfileService: ProfileService {
    func loadProfile(token: String) {

    }
}
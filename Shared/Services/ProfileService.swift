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

        let profile = Profile(name: "Marvin", points: 1000, games: 0, totalEarnings: 0, link: "bombastic.dev/u/123456")

        Just(profile)
                .sinkToLoadable {
                    weakAppState?[\.userData.profile] = $0
                }
                .store(in: cancelBag)
    }


}

struct StubProfileService: ProfileService {
    func loadProfile(token: String) {

    }
}
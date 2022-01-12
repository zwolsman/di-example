//
// Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation
import Combine
import CombineMoya

protocol ProfileService {
    func loadProfile(id: String, profile: LoadableSubject<Profile>)
    func loadMe()
}

struct RemoteProfileService: ProfileService {
    let appState: Store<AppState>
    let provider: APIProvider

    func loadProfile(id profileId: String, profile: LoadableSubject<Profile>) {
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)

        provider
                .requestPublisher(.profile(id: profileId))
                .map(Profile.self)
                .sinkToLoadable {
                    profile.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func loadMe() {
        let cancelBag = CancelBag()
        appState[\.userData.profile].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        provider
                .requestPublisher(.profile())
                .map(Profile.self)
                .sinkToLoadable {
                    weakAppState?[\.userData.profile] = $0
                }
                .store(in: cancelBag)
    }
}

struct StubProfileService: ProfileService {
    func loadProfile(id: String, profile: LoadableSubject<Profile>) {

    }

    func loadMe() {

    }

}

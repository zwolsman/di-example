//
// Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation
import Combine
import Moya

protocol ProfileService {
    func loadProfile()
}

class RemoteProfileService: ProfileService {
    let appState: Store<AppState>
    let provider: MoyaProvider<APIRepository>

    init(appState: Store<AppState>, provider: MoyaProvider<APIRepository>) {
        self.appState = appState
        self.provider = provider
    }

    func loadProfile() {
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
    func loadProfile() {

    }
}
//
// Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation
import Combine
import Moya

protocol ProfileService {
    func loadProfile(token: String)
}

class RemoteProfileService: ProfileService {
    let appState: Store<AppState>
    let provider: MoyaProvider<APIRepository>

    init(appState: Store<AppState>, provider: MoyaProvider<APIRepository>) {
        self.appState = appState
        self.provider = provider
    }

    func loadProfile(token: String) {
        let cancelBag = CancelBag()
        appState[\.userData.profile].setIsLoading(cancelBag: cancelBag)
        weak var weakAppState = appState

        provider
                .requestPublisher(.profile())
                .map(Profile.self, using: JSONDecoder())
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
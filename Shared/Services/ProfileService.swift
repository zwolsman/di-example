//
// Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation
import Combine
import CombineMoya

protocol ProfileService {
    func loadProfile(id: String, profile: LoadableSubject<Profile>)
    func loadProfileWithTransactions(profileWithTransaction: LoadableSubject<ProfileWithTransactions>)
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
    
    func loadProfileWithTransactions(profileWithTransaction: LoadableSubject<ProfileWithTransactions>) {
        let cancelBag = CancelBag()
        profileWithTransaction.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        provider
            .requestPublisher(.transactions)
            .map(ProfileWithTransactions.self, using: decoder)
            .sinkToLoadable {
                profileWithTransaction.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
}

struct StubProfileService: ProfileService {
    func loadProfile(id: String, profile: LoadableSubject<Profile>) {

    }

    func loadProfileWithTransactions(profileWithTransaction: LoadableSubject<ProfileWithTransactions>) {
        
    }
    
    func loadMe() {

    }

}

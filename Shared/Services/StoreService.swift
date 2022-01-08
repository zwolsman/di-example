//
// Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation
import Moya

protocol StoreService {
    func loadOffers(offers: LoadableSubject<[Offer]>)
    func purchase(offer: Offer, profile: LoadableSubject<Profile>)
}

struct OffersResponse: Decodable {
    var offers: [Offer]
}

struct RemoteStoreService: StoreService {
    let provider: MoyaProvider<APIRepository>

    init(provider: MoyaProvider<APIRepository>) {
        self.provider = provider
    }

    func loadOffers(offers: LoadableSubject<[Offer]>) {
        let cancelBag = CancelBag()
        offers.wrappedValue.setIsLoading(cancelBag: cancelBag)

        provider
                .requestPublisher(.storeOffers)
                .map(OffersResponse.self)
                .map(\.offers)
                .sinkToLoadable {
                    offers.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    let cancelBag = CancelBag()

    func purchase(offer: Offer, profile: LoadableSubject<Profile>) {
        provider
                .requestPublisher(.purchase(offerId: offer.offerId))
                .map(Profile.self)
                .sinkToLoadable {
                    profile.wrappedValue = $0
                }
                .store(in: cancelBag)
    }
}

struct StubStoreService: StoreService {

    func loadOffers(offers: LoadableSubject<[Offer]>) {

    }

    func purchase(offer: Offer, profile: LoadableSubject<Profile>) {

    }

}

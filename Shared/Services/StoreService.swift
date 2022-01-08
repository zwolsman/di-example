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

    func purchase(offer: Offer, profile: LoadableSubject<Profile>) {

    }
}

struct StubStoreService: StoreService {

    func loadOffers(offers: LoadableSubject<[Offer]>) {

    }

    func purchase(offer: Offer, profile: LoadableSubject<Profile>) {

    }

}
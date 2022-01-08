//
// Created by Marvin Zwolsman on 22/12/2021.
//

extension DIContainer {
    struct Services {
        let gameService: GameService
        let profileService: ProfileService
        let authService: AuthService
        let storeService: StoreService

        static var stub: Self {
            .init(gameService: StubGameService(), profileService: StubProfileService(), authService: StubAuthService(), storeService: StubStoreService())
        }
    }
}

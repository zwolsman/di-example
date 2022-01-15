//
// Created by Marvin Zwolsman on 22/12/2021.
//
#if os(iOS)
import UIKit
#endif
import Combine
import Moya

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {

    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let provider = configureAPIRepository()
        let services = configuredServices(appState: appState, provider: provider)

        let diContainer = DIContainer(appState: appState, services: services)
        return AppEnvironment(container: diContainer)
    }

    private static func configureAPIRepository() -> APIProvider {
        APIProvider(
                plugins: [
                    AccessTokenPlugin { _ in
                        #if os(iOS)
                        UserDefaults.standard.string(forKey: "access_token") ?? ""
                        #else
                        "TODO"
                        #endif
                    },
                    NetworkLoggerPlugin()
                ]
        )
    }

    private static func configuredServices(appState: Store<AppState>, provider: APIProvider) -> DIContainer.Services {

        let gameService = RemoteGameService(appState: appState, provider: provider)
        let profileService = RemoteProfileService(appState: appState, provider: provider)
        let authService = RemoteAuthService(provider: provider)
        let storeService = RemoteStoreService(provider: provider)

        return .init(
                gameService: gameService,
                profileService: profileService,
                authService: authService,
                storeService: storeService
        )
    }
}

//
// Created by Marvin Zwolsman on 22/12/2021.
//

import UIKit
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
                        UserDefaults.standard.string(forKey: "access_token") ?? ""
                    },
                    NetworkLoggerPlugin()
                ]
        )
    }

    private static func configuredServices(appState: Store<AppState>, provider: APIProvider) -> DIContainer.Services {

        let gameService = RemoteGameService(appState: appState, provider: provider)
        let profileService = RemoteProfileService(appState: appState, provider: provider)
        let authService = RemoteAuthService(provider: provider)

        return .init(
                gameService: gameService,
                profileService: profileService,
                authService: authService)
    }
}

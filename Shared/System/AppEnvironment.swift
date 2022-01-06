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

    private static func configureAPIRepository() -> MoyaProvider<APIRepository> {
        MoyaProvider<APIRepository>(
                plugins: [
                    AuthPlugin(tokenClosure: { UserDefaults.standard.string(forKey: "access_token") })
                ]
        )
    }

    private static func configuredServices(appState: Store<AppState>, provider: MoyaProvider<APIRepository>) -> DIContainer.Services {

        let gameService = LocalGameService(appState: appState, repo: LocalGameRepository())
        let profileService = RemoteProfileService(appState: appState, provider: provider)
        let authService = RemoteAuthService(provider: provider)

        return .init(gameService: gameService, profileService: profileService, authService: authService)
    }
}

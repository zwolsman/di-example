//
// Created by Marvin Zwolsman on 22/12/2021.
//

import UIKit
import Combine

struct AppEnvironment {
    let container: DIContainer
//    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {

    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let services = configuredServices(appState: appState)

        let diContainer = DIContainer(appState: appState, services: services)
        return AppEnvironment(container: diContainer)
    }

    private static func configuredServices(appState: Store<AppState>) -> DIContainer.Interactors {

        let gameService = LocalGameService()

        return .init(gameService: gameService)
    }
}
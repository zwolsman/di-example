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
        let interactors = configuredInteractors(appState: appState)

        let diContainer = DIContainer(appState: appState, interactors: interactors)
        return AppEnvironment(container: diContainer)
    }

    private static func configuredInteractors(appState: Store<AppState>) -> DIContainer.Interactors {

        let gamesInteractor = LocalGamesInteractor()

        return .init(gamesInteractor: gamesInteractor)
    }
}
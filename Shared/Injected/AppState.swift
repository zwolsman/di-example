//
// Created by Marvin Zwolsman on 22/12/2021.
//

import SwiftUI
import Combine

struct AppState: Equatable {
    var userData = UserData()
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct UserData: Equatable {
        var authenticated: Loadable<Bool> = .notRequested
        var games: Loadable<[Game]> = .notRequested
        var profile: Loadable<Profile> = .notRequested
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var homeScene = HomeScene.Routing()
        var gameScene = GameScene.Routing()
        var gameDetailsScene = GameInfoScene.Routing()
        var newGameScene = NewGameScene.Routing()
        var profileScene = ProfileScene.Routing()
        var welcomeScene = WelcomeScene.Routing()
        var connectWalletScene = ConnectWalletScene.Routing()
        var storeScene = StoreScene.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = true
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    lhs.userData == rhs.userData && lhs.routing == rhs.routing
}

extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.userData.games = .loaded(Game.mockedData)
        state.userData.profile = .loaded(Profile.mock)
        return state
    }
}

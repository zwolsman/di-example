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
        var games: Loadable<[Game]> = .notRequested
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var homeScene = HomeScene.Routing()
        var gameScene = GameScene.Routing()
        var newGameScene = NewGameScene.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = true
    }
}

func ==(lhs: AppState, rhs: AppState) -> Bool {
    lhs.userData == rhs.userData && lhs.routing == rhs.routing
}

extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.userData.games = .loaded(Game.mockedData)
        return state
    }
}
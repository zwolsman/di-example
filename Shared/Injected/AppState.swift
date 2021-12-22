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
        /*
         The list of countries (Loadable<[Country]>) used to be stored here.
         It was removed for performing countries' search by name inside a database,
         which made the resulting variable used locally by just one screen (CountriesList)
         Otherwise, the list of countries could have remained here, available for the entire app.
         */
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var homeScene = HomeScene.Routing()
        var gameScene = GameScene.Routing()
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
       AppState()
    }
}
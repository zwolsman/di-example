//
//  di_exampleApp.swift
//  Shared
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

@main
struct di_exampleApp: App {
    let environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            ContentView(container: environment.container)
        }
    }
}

//
//  di_exampleApp.swift
//  Shared
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

@main
struct BombasticApp: App {
    let environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(container: environment.container))
        }
    }
}

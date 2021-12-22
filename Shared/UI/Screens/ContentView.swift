//
//  ContentView.swift
//  Shared
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI
//import EnvironmentOverrides

struct ContentView: View {
    private let container: DIContainer
    private let isRunningTests: Bool

    init(container: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests) {
        self.container = container
        self.isRunningTests = isRunningTests
    }

    var body: some View {
        Group {
            if isRunningTests {
                Text("Running unit tests")
            } else {
                Text("Hello")
                        .inject(container)
//                CountriesList()
//                        .attachEnvironmentOverrides(onChange: onChangeHandler)
//                        .inject(container)
            }
        }
    }

//    var onChangeHandler: (EnvironmentValues.Diff) -> Void {
//        return { diff in
//            if !diff.isDisjoint(with: [.locale, .sizeCategory]) {
//                self.container.appState[\.routing] = AppState.ViewRouting()
//            }
//        }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: .preview)
    }
}

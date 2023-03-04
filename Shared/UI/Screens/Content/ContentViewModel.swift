//
// Created by Marvin Zwolsman on 12/01/2022.
//

import Foundation
import AuthenticationServices

// MARK: - ViewModel

extension ContentView {
    class ViewModel: ObservableObject {
        // State
        @Published var authenticated: Loadable<Bool>

        // Misc
        let container: DIContainer
        let isRunningTests: Bool
        private var cancelBag = CancelBag()

        init(container: DIContainer,
             authenticated: Loadable<Bool> = .notRequested,
             isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests) {
            print("content view created")
            self.container = container
            self.isRunningTests = isRunningTests
            let appState = container.appState
            _authenticated = .init(initialValue: authenticated)

            cancelBag.collect {
                appState.updates(for: \.userData.authenticated)
                        .weakAssign(to: \.authenticated, on: self)
            }
        }

        func loadAuthenticationState() {
//            container.appState[\.userData.authenticated].setIsLoading(cancelBag: cancelBag)
//            let hasAuth = UserDefaults.standard.string(forKey: "access_token") != nil
//            container.appState[\.userData.authenticated] = .loaded(hasAuth)
            container.appState[\.userData.authenticated] = .loaded(false)
        }
    }
}

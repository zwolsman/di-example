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
//            container.appState[\.userData.authenticated] = .loaded(false)
//            if let token = UserDefaults.standard.string(forKey: "access_token") {
//                container
//                    .services
//                    .authService
//                    .verify(token: token)
//                    .sinkToLoadable {
//                        self.container.appState[\.userData.authenticated] = $0
//                    }
//                    .store(in: cancelBag)
//            } else {
//                container.appState[\.userData.authenticated] = .loaded(false)
//            }
        }
    }
}

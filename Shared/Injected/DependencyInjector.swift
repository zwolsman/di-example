//
// Created by Marvin Zwolsman on 22/12/2021.
//

import SwiftUI
import Combine

// MARK: - DIContainer
struct DIContainer: EnvironmentKey {

    let appState: Store<AppState>
    let services: Services

    static var defaultValue: Self { Self.default }

    private static let `default` = DIContainer(appState: AppState(), services: .stub)

    init(appState: Store<AppState>, services: DIContainer.Services) {
        self.appState = appState
        self.services = services
    }

    init(appState: AppState, services: DIContainer.Services) {
        self.init(appState: Store(appState), services: services)
    }
}

extension EnvironmentValues {
    var injected: DIContainer {
        get {
            self[DIContainer.self]
        }
        set {
            self[DIContainer.self] = newValue
        }
    }
}

extension DIContainer {
    static var preview: Self {
        .init(appState: .preview, services: .stub)
    }
}

// MARK: - Injection in the view hierarchy
extension View {

    func inject(_ appState: AppState, _ services: DIContainer.Services) -> some View {
        let container = DIContainer(appState: appState, services: services)
        return inject(container)
    }

    func inject(_ container: DIContainer) -> some View {
        self
                .modifier(RootViewAppearance(viewModel: .init(container: container)))
    }
}

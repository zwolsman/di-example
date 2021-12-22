//
// Created by Marvin Zwolsman on 22/12/2021.
//

import SwiftUI
import Combine

struct RootViewAppearance: ViewModifier {

    @Environment(\.injected) private var injected: DIContainer
    @State private var isActive: Bool = false
    internal let inspection = Inspection<Self>()

    func body(content: Content) -> some View {
        content
                .blur(radius: isActive ? 0 : 10)
                .onReceive(stateUpdate) {
                    isActive = $0
                }
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    private var stateUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: \.system.isActive)
    }
}

//
// Created by Marvin Zwolsman on 22/12/2021.
//

import SwiftUI
import Combine

// MARK: - RootViewAppearance

struct RootViewAppearance: ViewModifier {

    @ObservedObject private(set) var viewModel: ViewModel
    internal let inspection = Inspection<Self>()

    func body(content: Content) -> some View {
        content
                .blur(radius: viewModel.isActive ? 0 : 10)
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }
}

extension RootViewAppearance {
    class ViewModel: ObservableObject {

        @Published var isActive: Bool = false
        private let cancelBag = CancelBag()

        init(container: DIContainer) {
            container.appState.map(\.system.isActive)
                    .removeDuplicates()
                    .weakAssign(to: \.isActive, on: self)
                    .store(in: cancelBag)
        }
    }
}

//
//  ContentView.swift
//  Shared
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

import Combine

// MARK: - View

struct ContentView: View {

    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        if viewModel.isRunningTests {
            Text("Running unit tests")
        } else {
            SignInScene(viewModel: .init(container: viewModel.container))
                    .modifier(RootViewAppearance(viewModel: .init(container: viewModel.container)))
        }
    }
}

// MARK: - ViewModel

extension ContentView {
    class ViewModel: ObservableObject {

        let container: DIContainer
        let isRunningTests: Bool

        init(container: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests) {
            self.container = container
            self.isRunningTests = isRunningTests
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel(container: .preview))
    }
}

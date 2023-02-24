//
//  ContentView.swift
//  Shared
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

// MARK: - View

struct ContentView: View {

    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        if viewModel.isRunningTests {
            Text("Running unit tests")
        } else {
            NavigationView {
                content
            }
                    .modifier(RootViewAppearance(viewModel: .init(container: viewModel.container)))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.authenticated {
        case .notRequested:
            notRequestedView
        case .isLoading:
            LoadingScreen()
        case .loaded(false), .failed:
            WelcomeScene(viewModel: .init(container: viewModel.container, authenticated: viewModel.authenticated))
        case .loaded(true):
            HomeScene(viewModel: .init(container: viewModel.container))
        }
    }

    private var notRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadAuthenticationState)
    }
}

// swiftlint:disable line_length
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel(container: .preview))
        ContentView(viewModel: ContentView.ViewModel(container: .preview, authenticated: .isLoading(last: nil, cancelBag: CancelBag())))
        ContentView(viewModel: ContentView.ViewModel(container: .preview, authenticated: .loaded(true)))
        ContentView(viewModel: ContentView.ViewModel(container: .preview, authenticated: .loaded(false)))
    }
}

// swiftlint:enable line_length

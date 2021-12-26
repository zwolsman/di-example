//
//  ProfileScene.swift
//  di-example
//
//  Created by Marvin Zwolsman on 26/12/2021.
//
//

import SwiftUI

struct ProfileScene: View {
    @ObservedObject private(set) var viewModel: ViewModel

    let inspection = Inspection<Self>()

    var body: some View {
        content
                .navigationBarTitle("Profile")
                .onReceive(inspection.notice) {
                    inspection.visit(self, $0)
                }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.profile {
        case .notRequested: notRequestedView
        case .isLoading: loadingView
        case let .loaded(profile): loadedView(profile)
        case let .failed(error): failedView(error)
        }
    }
}

// MARK: - Loading Content

private extension ProfileScene {
    var notRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadProfile)
    }

    var loadingView: some View {
        VStack {
            ActivityIndicatorView()
            Button(action: {
                viewModel.profile.cancelLoading()
            }, label: { Text("Cancel loading") })
        }
    }

    func failedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Content

private extension ProfileScene {
    func loadedView(_ profile: Profile) -> some View {
        VStack {
            Text("Profile")
        }
    }
}

struct ProfileScene_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScene(viewModel: .init(container: .preview, profileType: .`self`, profile: .loaded(Profile.mock)))
    }
}

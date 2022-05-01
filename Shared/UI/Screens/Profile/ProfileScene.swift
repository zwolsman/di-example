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
                .toolbar {
                    shareProfileButton
                }
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

    private var shareProfileButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: viewModel.shareProfile) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
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
            Button("Cancel loading") {
                viewModel.profile.cancelLoading()
            }
        }
    }

    func failedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

// MARK: - Displaying Content

private extension ProfileScene {
    func loadedView(_ profile: Profile) -> some View {
        List {
            Section {
                VStack(spacing: 4) {
                    Text(profile.name)
                        .fontWeight(.semibold)

                    Link(destination: URL(string: profile.link)!) {
                        Text(profile.link)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)

                }.padding()
                        .frame(maxWidth: .infinity)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    VStack {
                        Text("\(profile.bits.formatted())")
                                .fontWeight(.bold)
                        Text("Bits")
                    }
                    VStack {
                        Text("\(profile.games.formatted())")
                                .fontWeight(.bold)
                        Text("Games")
                    }

                    VStack {
                        Text("\(profile.bitsEarned.formatted())")
                                .fontWeight(.bold)
                        Text("Earned")
                    }

                }
                        .padding(.bottom)
            }.listRowSeparator(.hidden)

//            highlightSection(profile.highlights)
//
//            achievementSection(profile.achievements)

            Section {
                NavigationLink(destination: TransactionsScene(viewModel: .init(container: viewModel.container))) {
                    Text("Manage bits")
                }
            }
        }.listStyle(.insetGrouped)
    }

    func editableSection(text: String, editAction: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
            Spacer()
            if viewModel.profileType == .own {
                Button("Edit", action: editAction)
            }
        }
    }

    @ViewBuilder
    func highlightSection(_ highlights: [Game]) -> some View {
        if viewModel.profileType == .own || !highlights.isEmpty {
            Section(header: editableSection(text: "Highlights", editAction: {})) {
                if highlights.isEmpty {
                    Text("Show off your highlights here.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                } else {
                    ForEach(highlights) { game in
                        Text(game.id)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func achievementSection(_ achievements: [String]) -> some View {
        if viewModel.profileType == .own || !achievements.isEmpty {
            Section(header: editableSection(text: "Achievements", editAction: {})) {
                if achievements.isEmpty {
                    Text("Show off your achievements here.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                } else {
                    ForEach(achievements, id: \.self) { achievement in
                        Text(achievement)
                    }
                }
            }
        }
    }

}

struct ProfileScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileScene(viewModel: .init(container: .preview, profileType: .own, profile: .loaded(Profile.mock)))
        }

        NavigationView {
            ProfileScene(viewModel: .init(container: .preview, profileType: .other("id"), profile: .loaded(Profile.mockWithHighlights)))
                    .preferredColorScheme(.dark)
        }
    }
}

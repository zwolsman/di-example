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
        #if os(iOS)
                .navigationBarTitle("Profile")
        #elseif os(macOS)
                .navigationTitle("Profile")
        #endif
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
        #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: viewModel.shareProfile) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        #else
        ToolbarItem {
            Button(action: viewModel.shareProfile) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        #endif
    }
}

// MARK: - Loading Content

private extension ProfileScene {
    var notRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadProfile)
    }

    var loadingView: some View {
        VStack {
            ProgressView()
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
                VStack {
                    ZStack {
                        Circle()
                                .foregroundColor(.secondary.opacity(0.2))
                        Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .padding()
                    }
                    Text(profile.name)
                            .font(.headline)

                    Label(profile.link, systemImage: "link")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .padding(.trailing, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                }.padding()
                        .frame(maxWidth: .infinity)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    VStack {
                        Text("\(profile.points.formatted())")
                                .fontWeight(.bold)
                        Text("Points")
                    }
                    VStack {
                        Text("\(profile.games.formatted())")
                                .fontWeight(.bold)
                        Text("Games")
                    }

                    VStack {
                        Text("\(profile.totalEarnings.formatted())")
                                .fontWeight(.bold)
                        Text("Earned")
                    }

                }
                        .padding(.bottom)
            }
            #if os(iOS)
            .listRowSeparator(.hidden)
            #endif
//            highlightSection(profile.highlights)
//
//            achievementSection(profile.achievements)

            Section(footer: Text("Your balance is \(profile.balanceInEur.formatted(.currency(code: "EUR")))")) {
                NavigationLink(destination: storeScene) {
                    Text("Go to store")
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    }

    private func storeScene() -> some View {
        StoreScene(viewModel: .init(container: viewModel.container))
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

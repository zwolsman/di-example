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
                        
                        Label("https://bombastic.dev/1738", systemImage: "link")
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
            }.listRowSeparator(.hidden)
            
            Section(header: Text("Highlights")) {
                Text("A game")
            }
            
            Section(header: Text("Achievements")) {
                Text("An achievement")
            }
        }.listStyle(.insetGrouped)
    }
    
    
}

struct ProfileScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileScene(viewModel: .init(container: .preview, profileType: .`self`, profile: .loaded(Profile.mock)))
        }
    }
}

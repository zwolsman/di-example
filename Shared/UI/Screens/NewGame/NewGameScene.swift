//
//  NewGameScene.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

struct NewGameScene: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    let inspection = Inspection<Self>()
    
    var body: some View {
        content
            .navigationBarTitle("Create game", displayMode: .inline)
            .toolbar {
                headerText
            }
            .navigationBarBackButtonHidden()
            .onReceive(inspection.notice) {
                inspection.visit(self, $0)
            }
            .preferredColorScheme(.dark)
            .font(.custom("Carbon Bold", size: 18))
            .textCase(.uppercase)
    }
    
    private var headerText: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Create game")
                .font(.carbon(forTextStyle: .title3))
                .textCase(.uppercase)
        }
    }
    
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.profile {
        case let .isLoading(profile,_):
            loadingProfileView(profile)
        case let .loaded(profile):
            loadedView(profile)
        case .notRequested:
            profileNotRequestedView
        case let .failed(err):
            Text(err.localizedDescription)
        }
    }
    
    
}

private extension NewGameScene {
    var profileNotRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadProfile)
    }
    
    @ViewBuilder
    func loadingProfileView(_ previouslyLoaded: Profile?) -> some View {
        if let profile = previouslyLoaded {
            loadedView(profile, showLoading: true)
        } else {
            ActivityIndicatorView().padding()
        }
    }
    
    func profileFailedView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}


// MARK: - Displaying Content

private extension NewGameScene {
    func loadedView(_ profile: Profile, showLoading: Bool = false) -> some View {
        VStack {
            if showLoading {
                Text("Loading..")
            }
            
            Text("Your balance")
            Text(profile.address)
                .foregroundColor(.accentColor)
                .textCase(.none)
                .truncationMode(.middle)
                .lineLimit(1)
                .frame(maxWidth: 150)
            
            HStack(spacing: 4) {
                Text(profile.points.formatted())
                    .font(.system(size: 56).bold())
                Text("pts")
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading) {
                Text("# Bombs")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 6), spacing: 1) {
                    
                    ForEach(1...5, id: \.self) { amount in
                        Button(action: {
                            if viewModel.bombs == amount {
                                viewModel.bombs = 0
                            } else {
                                viewModel.bombs = amount
                            }
                        }) {
                            ZStack {
                                if viewModel.bombs >= amount {
                                    Image("check background")
                                        .resizable()
                                        .renderingMode(.template)
                                        .tint(.white)
                                        .scaledToFit()
                                    Image("bomb black")
                                } else {
                                    Image("check background")
                                        .resizable()
                                        .scaledToFit()
                                    Image("check")
                                }
                            }
                            .padding(12)
                            .background(Color("grey two"))
                        }
                    }
                    
                    VStack {
                        Text("\(viewModel.bombs)")
                        Text("\(viewModel.level)")
                    }
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(Color(viewModel.levelColor))
                    .background(Color("grey two"))
                }
                .padding([.trailing, .top, .leading], 1)
                .background(Color("grey"))
                .padding(8)
                .background(Color("grey two"))
            }
            .padding(.top)
            
            VStack(alignment: .leading) {
                Text("Initial stake")
                VStack {
                    TextField("Points", text: $viewModel.pointsText).keyboardType(.numberPad)
                        .font(.custom("Carbon Bold", size: 32))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .background(.black)
                        .frame(maxWidth: .infinity)
                        .border(Color("grey"))
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                        
                        ForEach([100, 250, 500], id: \.self) { amount in
                            Button("\(amount)") {
                                viewModel.pointsText = "\(amount)"
                            }
                            .selectedableButtonStyle(selected: viewModel.points == amount)
                        }
                        
                        Button(action: viewModel.setToMaxPoints) {
                            Text("Max")
                        }
                        .selectedableButtonStyle(selected: viewModel.points == viewModel.pointsRange.upperBound)
                    }
                }.padding(8)
                    .background(Color("grey two"))
            }
            .padding(.top)
            
            
            Spacer()
            
            if let game = viewModel.routingState.game {
                NavigationLink(destination: GameScene(viewModel: .init(container: viewModel.container, game: .loaded(game))), isActive: $viewModel.isInGame) {
                    EmptyView()
                }
            }
            
            Button("Create Game", action: viewModel.createGame)
                .primaryButtonStyle()
                .disabled(!viewModel.canCreateGame)
        }
        .padding()
        .alert(item: $viewModel.problem) {
            $0.alert
        }
    }
}

struct NewGameScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewGameScene(viewModel: .init(container: .preview))
        }
    }
}

//
//  CheckpotView.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 05/03/2023.
//

import SwiftUI

struct CheckpotView: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                Spacer()
                Image("check home")
                    .padding()
                Text("Checkpot")
                    .font(.carbon(forTextStyle: .largeTitle))
                Text("You won a William")
                    .font(.carbon(forTextStyle: .title2))
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                    Image("checkpot enabled")
                        .resizable()
                        .scaledToFill()
                    Image("checkpot disabled")
                        .resizable()
                        .scaledToFill()
                    Image("checkpot disabled")
                        .resizable()
                        .scaledToFill()
                    Image("checkpot disabled")
                        .resizable()
                        .scaledToFill()
                    Image("checkpot disabled")
                        .resizable()
                        .scaledToFill()
                }
                .padding()
                Spacer()
                Button("Start new game", action: {})
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
            }.font(.carbon())
                .presentationDetents([.height(400)])
                .padding()
                .textCase(.uppercase)
        } else {
            // Fallback on earlier versions
        }
            
    }
}

struct CheckpotView_Previews: PreviewProvider {
    static var previews: some View {
        VStack
        {
            
        }
            .sheet(isPresented: .constant(true)) {
                CheckpotView()
            }
            .preferredColorScheme(.dark)
    }
}

//
//  TransactionsScene.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 15/04/2022.
//

import SwiftUI

struct TransactionsScene: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct TransactionsScene_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScene(viewModel: .init(container: .preview))
    }
}

//
//  LoadingScreen.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 12/01/2022.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        VStack {
            BombasticLogo()
                    .id("logo")
            ProgressView()
        }
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}

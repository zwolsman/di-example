//
//  Styles.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 27/02/2023.
//

import SwiftUI

extension Button {
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
    }
    
    func selectedButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .scaledToFill()
            .padding(16)
            .foregroundColor(.black)
            .background(Color.accentColor)
    }
    
    func nonSelectedButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .scaledToFill()
            .padding(16)
            .border(Color("grey"))
            .foregroundColor(Color("grey"))
    }
}

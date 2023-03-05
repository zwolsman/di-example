//
//  Styles.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 27/02/2023.
//

import SwiftUI

extension Button {
    @warn_unqualified_access
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
    }
    
    @warn_unqualified_access
    func selectedableButtonStyle(selected: Bool) -> some View {
        self
            .frame(maxWidth: .infinity)
            .scaledToFill()
            .padding(16)
            .foregroundColor(selected ? .black : Color("grey"))
            .background(selected ? Color.accentColor : Color("grey two"))
            .border(selected ? Color.accentColor : Color("grey"))
    }
}

struct TableCellModifier : ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.black)
    }
}

struct TableHeaderModifier : ViewModifier {
    func body(content: Content) -> some View {
        content
            .modifier(TableCellModifier())
            .foregroundColor(Color("grey"))
    }
}

//
//  ColorCell.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

struct ColorCell: View {
    var color: Color

    var body: some View {
        HStack {
            Rectangle()
                    .foregroundColor(color)
                    .frame(maxWidth: 16, maxHeight: 16)
                    .aspectRatio(1, contentMode: .fill)
            Text(color.description.capitalized).tag(color)
        }
    }
}

struct ColorCell_Previews: PreviewProvider {
    static var previews: some View {
        List(Game.colors, id: \.self) {
            ColorCell(color: $0)
        }
    }
}

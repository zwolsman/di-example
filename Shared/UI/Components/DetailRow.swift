//
//  DetailRow.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

struct DetailRow: View {
    let left: AnyView
    let right: AnyView

    init(left: String, right: String) {
        self.left = AnyView(Text(left))
        self.right = AnyView(Text(right))
    }

    init(left: String, right: AnyView) {
        self.left = AnyView(Text(left))
        self.right = right
    }

    var body: some View {
        HStack {
            left
            Spacer()
            right
        }
    }
}

struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(left: "Left", right: "Right")
    }
}

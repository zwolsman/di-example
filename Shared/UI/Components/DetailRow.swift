//
//  DetailRow.swift
//  di-example
//
//  Created by Marvin Zwolsman on 22/12/2021.
//
//

import SwiftUI

struct DetailRow<Left: View, Right: View>: View {
    let left: Left
    let right: Right

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
        DetailRow(left: Text("Left"), right: Text("Right"))
    }
}

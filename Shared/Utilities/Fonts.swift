//
//  Fonts.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 24/02/2023.
//

import SwiftUI

extension Font {
    static func carbon(forTextStyle style: UIFont.TextStyle = .body) -> Font {
        .custom("Carbon Bold",  size: UIFont.preferredFont(forTextStyle: style).pointSize)
    }
    static func carbon(size: Int) -> Font {
        .custom("Carbon Bold",  size: CGFloat(size))
    }
}

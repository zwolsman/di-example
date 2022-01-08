//
// Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation

extension Collection {
    public func chunked(into size: Int) -> [SubSequence] {
        var chunks: [SubSequence] = []
        chunks.reserveCapacity((underestimatedCount + size - 1) / size)

        var residual = self[...], splitIndex = startIndex
        while formIndex(&splitIndex, offsetBy: size, limitedBy: endIndex) {
            chunks.append(residual.prefix(upTo: splitIndex))
            residual = residual.suffix(from: splitIndex)
        }

        return residual.isEmpty ? chunks : chunks + CollectionOfOne(residual)
    }
}

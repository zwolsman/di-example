//
// Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation

enum Tile: Equatable {
    case loading
    case bomb(revealedByUser: Bool)
    case points(amount: Int)
}

extension Tile {
    static func from(string source: String) -> (tileId: Int, tile: Tile)? {
        let tileTypeIndex = source.index(source.startIndex, offsetBy: 2)
        let stateIndex = source.index(after: tileTypeIndex)

        guard let tileId = Int(source[..<tileTypeIndex]) else {
            return nil
        }

        let state = source[stateIndex...]
        switch source[tileTypeIndex] {
        case "B":
            switch state {
            case "T", "F":
                return (tileId, .bomb(revealedByUser: state == "T"))
            default:
                return nil
            }
        case "P":
            let amount = Int(state)!
            return (tileId, .points(amount: amount))
        default:
            return nil
        }
    }
}

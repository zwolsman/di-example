//
//  GameRepository.swift
//  di-example
//
//  Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation

protocol GameRepository {
    func createGame(initialStake: Int, bombs: Int, colorId: Int) async -> RemoteGame
}

struct RemoteGame {
    var id: String

    var secret: String
    var plain: String?
    var bombs: [Int] // Normally private

    var stake: Int
    var next: Int?
    var initialBet: Int

    var colorId: Int
}

struct LocalGameRepository: GameRepository {

    func createGame(initialStake: Int, bombs: Int, colorId: Int) async -> RemoteGame {
        let bombLocations = generateBombs(amount: bombs)
        let plain = bombLocations.map(String.init).joined(separator: "-") + randomString(length: 16)
        let secret = plain.sha256()
        let next = try! calculateReward(emptyTiles: 25, bombs: bombs, stake: initialStake)

        return RemoteGame(id: UUID().uuidString,
                secret: secret,
                plain: nil,
                bombs: bombLocations,
                stake: initialStake,
                next: next,
                initialBet: initialStake,
                colorId: colorId
        )
    }

    private func generateBombs(amount: Int) -> [Int] {
        switch amount {
        case 1:
            return [Int.random(in: Game.TILE_RANGE)]
        case 3, 5:
            var bombs = [Int]()
            repeat {
                let rng = Int.random(in: Game.TILE_RANGE)
                if (!bombs.contains(rng)) {
                    bombs.append(rng)
                }
            } while (bombs.count < amount)

            return bombs
        case 24:
            let x = Int.random(in: Game.TILE_RANGE)
            return Game.TILE_RANGE.filter {
                $0 != x
            }
        default:
            return []
        }
    }

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let range = 0...length

        let chars = range.compactMap { _ in
            letters.randomElement()
        }

        return String(chars)
    }

    let STITCHING = 0.005

    private func calculateReward(emptyTiles: Int, bombs: Int, stake: Int) throws -> Int {
        let moves = 25 - emptyTiles
        let tiles = 25
        var odds = Double(tiles - moves) / Double(tiles - moves - bombs)
        odds *= (1 - STITCHING)
        return Int(floor(Double(stake) * odds)) - stake
    }

}

struct StubGameRepository: GameRepository {
    func createGame(initialStake: Int, bombs: Int, colorId: Int) async -> RemoteGame {
        RemoteGame(id: "", secret: "", plain: nil, bombs: [], stake: 0, next: 0, initialBet: 0, colorId: 0)
    }


}

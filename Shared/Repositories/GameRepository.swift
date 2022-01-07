//
//  GameRepository.swift
//  di-example
//
//  Created by Marvin Zwolsman on 02/01/2022.
//

import Foundation

protocol GameRepository {
    func createGame(initialStake: Int, bombs: Int, colorId: Int) async -> RemoteGame
    func guess(tileId: Int, gameId: String) async throws -> (Tile, RemoteGame)
    func cashOut(gameId: String) async throws -> RemoteGame
}

struct InternalGame {
    var id: String

    var secret: String
    var plain: String
    var bombs: [Int]

    var stake: Int {
        initialBet + tiles.values.map { tile in
            switch tile {
            case .points(let amount):
                return amount
            default:
                return 0
            }
        }.reduce(0, +)
    }

    var next: Int
    var initialBet: Int

    var colorId: Int
    var tiles = [Int: Tile]()
    var state = State.inGame
    var multiplier: Double {
        Double(stake) / Double(initialBet)
    }

    func toRemoteGame() -> RemoteGame {
        RemoteGame(id: id, secret: secret, plain: state == .inGame ? nil : plain, tiles: tiles, state: state, initialBet: initialBet, stake: stake, next: next, multiplier: multiplier, bombs: bombs.count, colorId: colorId)
    }
}

struct RemoteGame {
    var id: String

    var secret: String
    var plain: String?
    var tiles: [Int: Tile]
    var state: State

    var initialBet: Int
    var stake: Int
    var next: Int
    var multiplier: Double
    var bombs: Int


    var colorId: Int
}

// TODO: leaky
enum Tile: Equatable {
    case loading
    case bomb(revealedByUser: Bool)
    case points(amount: Int)
}

enum State: Equatable {
    case inGame
    case gameOver(reason: Reason)

    enum Reason: Equatable {
        case hitBomb
        case cashedOut
    }
}

class LocalGameRepository: GameRepository {

    enum APIErrors: Error {
        case gameNotFound(gameId: String)
        case tileAlreadyGuessed(tileId: Int)
        case illegalAction(reason: String)
    }

    private(set) var games: [String: InternalGame] = [:]

    func createGame(initialStake: Int, bombs: Int, colorId: Int) async -> RemoteGame {
        let bombLocations = generateBombs(amount: bombs)
        let plain = bombLocations.map(String.init).joined(separator: "-") + "-" + randomString(length: 16)
        let secret = plain.sha256()
        let next = try! calculateReward(emptyTiles: 25, bombs: bombs, stake: initialStake)

        let game = InternalGame(id: UUID().uuidString,
                secret: secret,
                plain: plain,
                bombs: bombLocations,
                next: next,
                initialBet: initialStake,
                colorId: colorId
        )

        games[game.id] = game
        return game.toRemoteGame()
    }

    func guess(tileId: Int, gameId: String) async throws -> (Tile, RemoteGame) {
        guard var internalGame = games[gameId] else {
            throw APIErrors.gameNotFound(gameId: gameId)
        }

        guard internalGame.tiles.index(forKey: tileId) == nil else {
            throw APIErrors.tileAlreadyGuessed(tileId: tileId)
        }

        if internalGame.bombs.contains(tileId) {
            for bombTile in internalGame.bombs {
                internalGame.tiles[bombTile] = .bomb(revealedByUser: bombTile == tileId)
            }
            internalGame.state = .gameOver(reason: .hitBomb)
        } else {
            internalGame.tiles[tileId] = .points(amount: internalGame.next)
            internalGame.next = (try? calculateReward(emptyTiles: 25 - internalGame.tiles.count, bombs: internalGame.bombs.count, stake: internalGame.stake)) ?? internalGame.next
        }
        games[internalGame.id] = internalGame

        return (internalGame.tiles[tileId]!, internalGame.toRemoteGame())
    }

    func cashOut(gameId: String) async throws -> RemoteGame {
        guard var internalGame = games[gameId] else {
            throw APIErrors.gameNotFound(gameId: gameId)
        }

        guard internalGame.state == .inGame else {
            throw APIErrors.illegalAction(reason: "Game is already finished")
        }

        internalGame.state = .gameOver(reason: .cashedOut)
        for bombTile in internalGame.bombs {
            internalGame.tiles[bombTile] = .bomb(revealedByUser: false)
        }

        games[internalGame.id] = internalGame

        return internalGame.toRemoteGame()
    }

    // MARK: - Create game logic
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
        RemoteGame(id: "", secret: "", plain: nil, tiles: [:], state: .inGame, initialBet: 0, stake: 0, next: 0, multiplier: 0, bombs: 0, colorId: 0)
    }

    func guess(tileId: Int, gameId: String) async -> (Tile, RemoteGame) {
        (.points(amount: 1), RemoteGame(id: "", secret: "", plain: nil, tiles: [:], state: .inGame, initialBet: 0, stake: 0, next: 0, multiplier: 0, bombs: 0, colorId: 0))
    }

    func cashOut(gameId: String) async throws -> RemoteGame {
        RemoteGame(id: "", secret: "", plain: nil, tiles: [:], state: .inGame, initialBet: 0, stake: 0, next: 0, multiplier: 0, bombs: 0, colorId: 0)
    }

}

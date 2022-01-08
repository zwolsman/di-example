//
// Created by Marvin Zwolsman on 08/01/2022.
//

import Foundation

extension AppState {

    mutating func consume(game: Game) {
        userData.games = userData.games.map { storedGames -> [Game] in
            var games = storedGames
            guard let index = games.firstIndex(where: { $0.id == game.id }) else {
                games.insert(game, at: 0)
                return games
            }

            games[index] = game
            return games
        }
    }

    mutating func consume(profile: Profile) {
        userData.profile = userData.profile.map { _ in
            profile
        }
    }

}

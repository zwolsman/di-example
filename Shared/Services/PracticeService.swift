//
//  PracticeService.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 21/03/2023.
//

import Foundation

protocol PracticeService {
    func create(game: LoadableSubject<Game>)
    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int)
}


struct RemotePracticeService: PracticeService {
    let provider: APIProvider
    let globalCancelBag = CancelBag()
    
    func create(game: LoadableSubject<Game>) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        provider
                .requestPublisher(.createPracticeGame)
                .map(GameResponse.self)
                .map(GameResponse.toDomain)
                .extractProblem()
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }

    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {
        let cancelBag = CancelBag()
        game.wrappedValue.setIsLoading(cancelBag: cancelBag)

        game.wrappedValue = game.wrappedValue.map {
            var game = $0
            game.tiles[tileId] = .loading
            return game
        }

        provider
                .requestPublisher(.practiceGuess(gameId: gameId, tileId: tileId))
                .map(GameResponse.self)
                .map(GameResponse.toDomain)
                .sinkToLoadable {
                    game.wrappedValue = $0
                }
                .store(in: cancelBag)
    }
}

struct StubPracticeService: PracticeService {
    func create(game: LoadableSubject<Game>) {
        
    }
    
    func guess(game: LoadableSubject<Game>, gameId: String, tileId: Int) {
        
    }
}

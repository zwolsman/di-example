//
// Created by Marvin Zwolsman on 06/01/2022.
//

import Foundation
import Moya

typealias APIProvider = MoyaProvider<APIRepository>

enum APIRepository {
    case profile(id: String? = nil)
    case games
    case game(id: String)
    case deleteGame(id: String)
    case createGame(initialBet: Int, bombs: Int, colorId: Int)
    case createPracticeGame
    case guess(gameId: String, tileId: Int)
    case practiceGuess(gameId: String, tileId: Int)
    case cashOut(gameId: String)
    case siwe(address: String)
    case verify(message: String, signatue: String)
    case storeOffers
    case purchase(offerId: String)
    case jwks
}

struct SignUpPayload: Codable {
    var address: String
}

struct VerifyPayload: Codable {
    var message: String
    var signature: String
}

struct CreateGamePayload: Codable {
    var initialBet: Int
    var bombs: Int
    var colorId: Int
}

// MARK: - TargetType Protocol Implementation
extension APIRepository: AccessTokenAuthorizable, TargetType {
    var authorizationType: AuthorizationType? {
        switch self {
        case .siwe, .verify, .jwks:
            return nil
        default:
            return .bearer
        }
    }

    var baseURL: URL {
        let scheme: String = try! Configuration.value(for: "API_SCHEME")
        let base: String = try! Configuration.value(for: "API_BASE")
        let url = URL(string: "\(scheme)://\(base)")!
        print("api base url: \(url)")
        return url
    }

    var path: String {
        switch self {
        case .profile(let id):
            guard let profileId = id else {
                return "/v1/profiles/me"
            }
            return "/v1/profiles/\(profileId)"

        case .games, .createGame:
            return "/v1/games"
        case let .game(gameId), let .deleteGame(gameId):
            return "/v1/games/\(gameId)"
        case let .guess(gameId, _):
            return "/v1/games/\(gameId)/guess"
        case let .cashOut(gameId):
            return "/v1/games/\(gameId)/cash-out"
        case .siwe:
            return "/v1/auth/siwe"
        case .verify:
            return "/v1/auth/verify"
        case .storeOffers:
            return "/v1/store/offers"
        case let .purchase(offerId):
            return "/v1/store/offers/\(offerId)/purchase"
        case .jwks:
            return "/v1/auth/keys"
        case .createPracticeGame:
            return "/v1/practice"
        case let .practiceGuess(gameId: gameId, tileId: _):
            return "/v1/practice/\(gameId)/guess"
        }
    }

    var method: Moya.Method {
        switch self {
        case .profile:
            return .get
        case .game, .games:
            return .get
        case .createGame, .createPracticeGame:
            return .post
        case .guess, .practiceGuess:
            return .put
        case .cashOut:
            return .put
        case .siwe, .verify:
            return .post
        case .storeOffers:
            return .get
        case .purchase:
            return .post
        case .deleteGame:
            return .delete
        case .jwks:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .profile, .game, .games, .cashOut, .storeOffers, .purchase, .deleteGame, .jwks, .createPracticeGame:
            return .requestPlain
        case let .siwe(address):
            let payload = SignUpPayload(address: address)
            return .requestJSONEncodable(payload)
        case let .verify(message, signature):
            let payload = VerifyPayload(message: message, signature: signature)
            return .requestJSONEncodable(payload)
        case let .createGame(initialBet, bombs, colorId):
            let payload = CreateGamePayload(initialBet: initialBet, bombs: bombs, colorId: colorId)
            return .requestJSONEncodable(payload)
        case let .guess(_, tileId), let .practiceGuess(_, tileId):
            return .requestParameters(parameters: ["tileId": tileId], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }

}

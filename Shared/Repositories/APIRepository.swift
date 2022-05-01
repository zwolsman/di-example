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
    case guess(gameId: String, tileId: Int)
    case cashOut(gameId: String)
    case signUp(fullName: String, authCode: String, identityToken: String)
    case verify(authCode: String, identityToken: String)
    case jwks
    case transactions
}

struct SignUpPayload: Codable {
    var fullName: String
    var authCode: String
    var identityToken: String
}

struct VerifyPayload: Codable {
    var authCode: String
    var identityToken: String
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
        case .signUp, .verify, .jwks:
            return nil
        default:
            return .bearer
        }
    }

    var baseURL: URL {
//        #if RELEASE
        let url = URL(string: "https://bombastic.joell.dev/api")!
//        #else
//        let url = URL(string: "http://192.168.1.120:8080/api")!
//        #endif
//        let url = URL(string: "http://172.28.244.43:8080/api")!
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
        case .transactions:
            return "/v1/profiles/me/transactions"
        case .games, .createGame:
            return "/v1/games"
        case let .game(gameId), let .deleteGame(gameId):
            return "/v1/games/\(gameId)"
        case let .guess(gameId, _):
            return "/v1/games/\(gameId)/guess"
        case let .cashOut(gameId):
            return "/v1/games/\(gameId)/cash-out"
        case .signUp:
            return "/v1/auth/sign-up"
        case .verify:
            return "/v1/auth/verify"
        case .jwks:
            return "/v1/auth/keys"
        }
    }

    var method: Moya.Method {
        switch self {
        case .profile, .transactions:
            return .get
        case .game, .games:
            return .get
        case .createGame:
            return .post
        case .guess:
            return .put
        case .cashOut:
            return .put
        case .signUp, .verify:
            return .post
        case .deleteGame:
            return .delete
        case .jwks:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .profile, .game, .games, .cashOut, .deleteGame, .jwks, .transactions:
            return .requestPlain

        case let .signUp(fullName, authCode, identityToken):
            let payload =
                    SignUpPayload(fullName: fullName, authCode: authCode, identityToken: identityToken)
            return .requestJSONEncodable(payload)
        case let .verify(authCode, identityToken):
            let payload = VerifyPayload(authCode: authCode, identityToken: identityToken)
            return .requestJSONEncodable(payload)
        case let .createGame(initialBet, bombs, colorId):
            let payload = CreateGamePayload(initialBet: initialBet, bombs: bombs, colorId: colorId)
            return .requestJSONEncodable(payload)
        case let .guess(_, tileId):
            return .requestParameters(parameters: ["tileId": tileId], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }

}

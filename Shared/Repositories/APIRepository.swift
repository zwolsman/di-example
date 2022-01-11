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
    case signUp(email: String, fullName: String, authCode: String, identityToken: String)
    case verify(authCode: String, identityToken: String)
    case storeOffers
    case purchase(offerId: String)
}

struct SignUpPayload: Codable {
    var email: String
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
extension APIRepository: AuthorizedTargetType {
    var needsAuth: Bool {
        switch self {
        case .signUp, .verify:
            return false
        default:
            return true
        }
    }

    var baseURL: URL {
        #if RELEASE
        let url = URL(string: "https://bombastic.joell.dev/api")!
        #else
        let url = URL(string: "http://192.168.1.120:8080/api")!
        #endif
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
        case .signUp:
            return "/v1/auth/sign-up"
        case .verify:
            return "/v1/auth/verify"
        case .storeOffers:
            return "/v1/store/offers"
        case let .purchase(offerId):
            return "/v1/store/offers/\(offerId)/purchase"
        }
    }

    var method: Moya.Method {
        switch self {
        case .profile:
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
        case .storeOffers:
            return .get
        case .purchase:
            return .post
        case .deleteGame:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .profile, .game, .games, .cashOut, .storeOffers, .purchase, .deleteGame:
            return .requestPlain

        case let .signUp(email, fullName, authCode, identityToken):
            let payload =
                    SignUpPayload(email: email, fullName: fullName, authCode: authCode, identityToken: identityToken)
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

// MARK: - Auth plugin
class TokenSource {
    var token: String?

    init() {
    }
}

protocol AuthorizedTargetType: TargetType {
    var needsAuth: Bool { get }
}

struct AuthPlugin: PluginType {
    let tokenClosure: () -> String?

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard
                let token = tokenClosure(),
                let target = target as? AuthorizedTargetType,
                target.needsAuth
                else {
            return request
        }

        var request = request
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
}

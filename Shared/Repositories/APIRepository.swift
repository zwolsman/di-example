//
// Created by Marvin Zwolsman on 06/01/2022.
//

import Foundation
import Moya

enum APIRepository {
    case profile(id: String? = nil)
    case games
    case signUp(email: String, fullName: String, authCode: String, identityToken: String)
    case verify(authCode: String, identityToken: String)
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
        URL(string: "http://192.168.1.120:8080/api")!
    }

    var path: String {
        switch self {
        case .profile(let id):
            guard let profileId = id else {
                return "/v1/profiles/me"
            }
            return "/v1/profiles/\(profileId)"

        case .games:
            return "/v1/games"
        case .signUp:
            return "/v1/auth/sign-up"
        case .verify:
            return "/v1/auth/verify"
        }
    }

    var method: Moya.Method {
        switch self {
        case .profile:
            return .get
        case .games:
            return .get
        case .signUp, .verify:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .profile, .games:
            return .requestPlain

        case let .signUp(email, fullName, authCode, identityToken):
            let payload = SignUpPayload(email: email, fullName: fullName, authCode: authCode, identityToken: identityToken)
            return .requestJSONEncodable(payload)
        case let .verify(authCode, identityToken):
            let payload = VerifyPayload(authCode: authCode, identityToken: identityToken)
            return .requestJSONEncodable(payload)
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

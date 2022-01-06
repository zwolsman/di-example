//
// Created by Marvin Zwolsman on 06/01/2022.
//

import Foundation
import Moya

enum APIRepository {
    case profile(id: String? = nil)
    case games
    case signUp(email: String, fullName: String, authCode: String, identityToken: String)
}

struct SignUpPayload: Codable {
    var email: String
    var fullName: String
    var authCode: String
    var identityToken: String
}

// MARK: - TargetType Protocol Implementation
extension APIRepository: TargetType {
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
        case .signUp(email: _, fullName: _, authCode: _, identityToken: _):
            return "/v1/auth/sign-up"
        }
    }

    var method: Moya.Method {
        switch self {
        case .profile:
            return .get
        case .games:
            return .get
        case .signUp(email: _, fullName: _, authCode: _, identityToken: _):
            return .post
        }
    }

    var task: Task {
        switch self {
        case .profile, .games:
            return .requestPlain

        case .signUp(email: let email, fullName: let fullName, authCode: let authCode, identityToken: let identityToken):
            let payload = SignUpPayload(email: email, fullName: fullName, authCode: authCode, identityToken: identityToken)
            return .requestJSONEncodable(payload)
        }
    }

    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }

}



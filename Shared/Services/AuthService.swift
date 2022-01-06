//
//  AuthService.swift
//  di-example
//
//  Created by Marvin Zwolsman on 04/01/2022.
//

import Foundation
import Combine
import Moya

protocol AuthService {
    func register(email: String, fullName: String, authCode: String, identityToken: String) -> AnyPublisher<String, MoyaError>
    func verify(authCode: String, identityToken: String) -> AnyPublisher<String, MoyaError>
}

struct TokenResponse: Decodable {
    var accessToken: String
}

class RemoteAuthService: AuthService {
    let provider: MoyaProvider<APIRepository>

    init(provider: MoyaProvider<APIRepository>) {
        self.provider = provider
    }

    func register(email: String, fullName: String, authCode: String, identityToken: String) -> AnyPublisher<String, MoyaError> {
        provider
                .requestPublisher(.signUp(email: email, fullName: fullName, authCode: authCode, identityToken: identityToken))
                .map(TokenResponse.self, using: JSONDecoder())
                .map(\.accessToken)
                .eraseToAnyPublisher()
    }
    func verify(authCode: String, identityToken: String) -> AnyPublisher<String, MoyaError> {
        provider
                .requestPublisher(.verify(authCode: authCode, identityToken: identityToken))
                .map(TokenResponse.self, using: JSONDecoder())
                .map(\.accessToken)
                .eraseToAnyPublisher()
    }
}

class StubAuthService: AuthService {
    func register(email: String, fullName: String, authCode: String, identityToken: String) -> AnyPublisher<String, MoyaError> {
        Empty<String, MoyaError>().eraseToAnyPublisher()
    }
    func verify(authCode: String, identityToken: String) -> AnyPublisher<String, MoyaError> {
        Empty<String, MoyaError>().eraseToAnyPublisher()
    }
}

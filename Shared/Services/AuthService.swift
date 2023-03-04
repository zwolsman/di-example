//
//  AuthService.swift
//  di-example
//
//  Created by Marvin Zwolsman on 04/01/2022.
//

import Foundation
import Combine
import Moya
import CombineMoya
import JWTKit
import CryptoSwift

protocol AuthService {
    func verify(token: String) -> AnyPublisher<Bool, Never>
    
    func verify(message: String, signature: String) -> AnyPublisher<String, MoyaError>
    func siwe(address: String) -> AnyPublisher<String, MoyaError>
}

struct SiweResponse: Decodable {
    var message: String
}
struct TokenResponse: Decodable {
    var accessToken: String
}

struct RemoteAuthService: AuthService {
    let provider: APIProvider
    
    func siwe(address: String) -> AnyPublisher<String, MoyaError> {
        provider
            .requestPublisher(
                .siwe(address: address)
            )
            .map(SiweResponse.self)
            .map(\.message)
            .eraseToAnyPublisher()
    }
    
    func verify(message: String, signature: String) -> AnyPublisher<String, MoyaError> {
        provider
            .requestPublisher(.verify(message: message, signatue: signature))
            .map(TokenResponse.self)
            .flatMap { response in
                verify(token: response.accessToken)
                    .filter { $0 }
                    .map { _ in
                        response.accessToken
                    }
            }
            .eraseToAnyPublisher()
    }
    
    func verify(token: String) -> AnyPublisher<Bool, Never> {
        provider
            .requestPublisher(.jwks)
            .map(JWKS.self)
            .tryMap { jwks in
                let signers = JWTSigners()
                try signers.use(jwks: jwks)
                let _ = try signers.verify(token, as: Payload.self)
                print("valid token: \(token)")
                return true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    private struct Payload: JWTPayload, Equatable {
        enum CodingKeys: String, CodingKey {
            case subject = "sub"
            case audience = "aud"
        }
        var subject: SubjectClaim
        var audience: AudienceClaim
        
        
        func verify(using signer: JWTSigner) throws {
            try self.audience.verifyIntendedAudience(includes: Bundle.main.bundleIdentifier!)
        }
    }
}

class StubAuthService: AuthService {
    func siwe(address: String)
    -> AnyPublisher<String, MoyaError> {
        Empty<String, MoyaError>().eraseToAnyPublisher()
    }
    
    func verify(message: String, signature: String) -> AnyPublisher<String, MoyaError> {
        Empty<String, MoyaError>().eraseToAnyPublisher()
    }
    
    func verify(token: String) -> AnyPublisher<Bool, Never> {
        Empty<Bool, Never>().eraseToAnyPublisher()
    }
}

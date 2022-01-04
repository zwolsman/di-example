//
//  AuthService.swift
//  di-example
//
//  Created by Marvin Zwolsman on 04/01/2022.
//

import Foundation

protocol AuthService {
    
    func register(email: String, fullName: PersonNameComponents, token: String, authCode: String) async throws -> SimpleProfile
    func validate(token: String, authCode: String, user: String) async throws -> SimpleProfile
}

struct SimpleProfile : Decodable {
    var name: String
    var points: Int
}

struct RegisterPayload: Codable {
    var email: String
    var user: PersonNameComponents
    var token: String
    var authCode: String
}

struct ValidatePayload : Codable {
    var token: String
    var authCode: String
    var user: String
}

class RemoteAuthService : AuthService {
    func register(email: String, fullName: PersonNameComponents, token: String, authCode: String) async throws -> SimpleProfile {
        let url = URL(string: "http://192.168.1.120:8080/v1/profile")!
        let payload = RegisterPayload(email: email, user: fullName, token: token, authCode: authCode)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)



        let (data, result) = try await URLSession.shared.data(for: request)
        print(result)
        // Parse the JSON data
        let profile = try JSONDecoder().decode(SimpleProfile.self, from: data)
        return profile
    }
    
    func validate(token: String, authCode: String, user: String) async throws -> SimpleProfile {
        let url = URL(string: "http://192.168.1.120:8080/v1/profile/validate")!
        let payload = ValidatePayload(token: token, authCode: authCode, user: user)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)



        let (data, result) = try await URLSession.shared.data(for: request)
        print(result)
        print(String(data: data, encoding: .utf8)!)
        
        // Parse the JSON data
        let profile = try JSONDecoder().decode(SimpleProfile.self, from: data)
        return profile
    }
    
    
}

class StubAuthService : AuthService {
    func register(email: String, fullName: PersonNameComponents, token: String, authCode: String) async -> SimpleProfile {
        SimpleProfile(name: "stub", points: 0)
    }
    
    func validate(token: String, authCode: String, user: String) async throws -> SimpleProfile {
        SimpleProfile(name: "stub", points: 0)
    }
}

//
//  Models.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 28/06/22.
//

import Foundation

// MARK: Network Responses
struct LoginResponse: Codable {
    var message: String?
    var token: String?
    
    var decodedToken: JWTTokenContent? {
        if let token = self.token {
            let result = try? decode(jwtToken: token, as: JWTTokenContent.self)
            return result
        }
        return nil
    }
    
    private func decode<T: Decodable>(jwtToken jwt: String, as type: T.Type) throws -> T? {
        
        func base64Decode(_ base64: String) throws -> Data? {
            let base64 = base64
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            guard let decoded = Data(base64Encoded: padded, options: .ignoreUnknownCharacters) else {
                return nil
            }
            return decoded
        }

        func decodeJWTPart(_ value: String) throws -> T? {
            if let bodyData = try base64Decode(value) {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .base64
                return try? decoder.decode(T.self, from: bodyData)
            }
            
            return nil
        }

        let segments = jwt.components(separatedBy: ".")
        return try decodeJWTPart(segments[1])
    }
}

struct JWTTokenContent: Codable {
//    // Define key mapping with JSON
    enum CodingKeys: String, CodingKey {
        case user, iat, exp
        case dashxToken = "dashx_token"
    }
    
    var user: User?
    var dashxToken: String?
    var iat: Int?
    var exp: Int?
}

struct ErrorResponse: Codable {
    var message: String?
}

// Used for responses with only "message" field e.g. signup / forgot password
typealias MessageResponse = ErrorResponse

// MARK: Business Data Models
struct User: Codable {
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
}

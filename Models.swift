//
//  Models.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 28/06/22.
//

import Foundation
import DashX

// MARK: -  Network Responses

// MARK: - LoginResponse
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

// MARK: - UpdateProfileResponse
struct UpdateProfileResponse: Codable {
    var user: User?
}

// MARK: - PostsResponse
struct PostsResponse: Codable {
    let posts: [Post]
}

// MARK: - AddPostResponse
struct AddPostResponse: Codable {
    let message: String
    let post: Post
}

// MARK: - Post
struct Post: Codable {
    let id, userID: Int
    let text: String
    // MARK: Type isn't defined, always null
    // let image, video: Type Don't know?
    let createdAt, updatedAt: String
    let bookmarkedAt: String?
    let user: User
    var isBookmarked: Bool {
        bookmarkedAt != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case text
        // case image, video
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case bookmarkedAt = "bookmarked_at"
        case user
    }
}

// MARK: - JWTTokenContent
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

// MARK: - ErrorResponse
struct ErrorResponse: Codable {
    var message: String?
}

// MARK: - ContactUsResponse
struct ContactUsResponse: Codable {
    var message: String
}

// MARK: - BookmarksResponse
struct BookmarksResponse: Codable {
    let message: String
    let bookmarks: [Bookmark]
}

// MARK: - NoResponse
struct NoResponse: Codable {
    init() { }
}

// MARK: - Bookmark
struct Bookmark: Codable {
    let id, userID: Int
    let text: String
    // MARK: Type isn't defined, always null
    // let image, video: Type Don't know?
    let createdAt, updatedAt: String
    let bookmarkID: Int
    let bookmarkedAt: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case text
        // case image, video
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case bookmarkID = "bookmark_id"
        case bookmarkedAt = "bookmarked_at"
        case user
    }
}

// MARK: - MessageResponse
// Used for responses with only "message" field e.g. signup / forgot password
typealias MessageResponse = ErrorResponse

// MARK: Business Data Models

// MARK: - User
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
    
    var name: String {
        var temp = firstName ?? ""
        if firstName != nil {
            temp = temp + " "
        }
        temp = temp + (lastName ?? "")
        return temp
    }
    
    var idString: String? {
        id == nil ? nil : String(id!)
    }
}

// MARK: - PreferenceDataResponse
struct PreferenceDataResponse: Codable {
    let newBookmark: DashX.Preference
    let newPost: DashX.Preference
        
    var newBookmarkNotificationEnabled: Bool {
        newBookmark.enabled ?? false
    }
    
    var newPostNotificationEnabled: Bool {
        newPost.enabled ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case newBookmark = "new-bookmark"
        case newPost = "new-post"
    }
}

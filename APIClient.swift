//
//  RestAPIs.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 24/06/22.
//

import Foundation

// SwaggerDoc is available at the below URL
let demoServerBaseUrl = "https://node.dashxdemo.com"

class APIClient {
    private static let network = NetworkUtils(baseURL: demoServerBaseUrl)
    
    static func loginUser(email: String,
                          password: String,
                          onSuccess: @escaping (LoginResponse?) -> Void,
                          onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/login"
        let params: NSDictionary = [
            "email": email,
            "password": password
        ]
        
        network.makeAPICall(path: path, params: params, onSuccess: onSuccess, onError: onError)
    }
    
    static func registerUser(firstName: String,
                             lastName: String,
                             email: String,
                             password: String,
                             onSuccess: @escaping (MessageResponse?) -> Void,
                             onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/register"
        let params: NSDictionary = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": password
        ]
        
        network.makeAPICall(path: path, params: params, onSuccess: onSuccess, onError: onError)
    }
    
    static func forgotPassword(email: String,
                               onSuccess: @escaping (MessageResponse?) -> Void,
                               onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/forgot-password"
        let params: NSDictionary = [
            "email": email
        ]
        
        network.makeAPICall(path: path, params: params, onSuccess: onSuccess, onError: onError)
    }
    
    static func updateProfile(firstName: String,
                              lastName: String,
                              email: String,
                              onSuccess: @escaping (UpdateProfileResponse?) -> Void,
                              onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/update-profile"
        let params: NSDictionary = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email
        ]
        
        network.makeAPICall(path: path, httpMethod: .patch, params: params, onSuccess: onSuccess, onError: onError)
    }
    
    static func getPosts(onSuccess: @escaping (PostsResponse?) -> Void,
                         onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/posts"
        
        network.makeAPICall(path: path, httpMethod: .get, onSuccess: onSuccess, onError: onError)
    }
    
    static func addPost(text: String,
                        onSuccess: @escaping (AddPostResponse?) -> Void,
                        onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/posts"
        let params: NSDictionary = [
            "text": text
        ]
        
        network.makeAPICall(path: path, params: params, onSuccess: onSuccess, onError: onError)
    }
    
    static func contactUs(name: String,
                          email: String,
                          feedback: String,
                          onSuccess: @escaping (ContactUsResponse?) -> Void,
                          onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/contact"
        let params: NSDictionary = [
            "name": name,
            "email": email,
            "feedback" : feedback
        ]
        
        network.makeAPICall(path: path, params: params, onSuccess: onSuccess, onError: onError)
    }
    
    static func getBookmarks(onSuccess: @escaping (PostsResponse?) -> Void,
                             onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/posts/bookmarked"
        
        network.makeAPICall(path: path, httpMethod: .get, onSuccess: onSuccess, onError: onError)
    }
    
    static func toggleBookmark(postId: Int,
                               onSuccess: @escaping (NoResponse?) -> Void,
                               onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/posts/\(postId)/toggle-bookmark"
        
        network.makeAPICall(path: path, httpMethod: .put, onSuccess: onSuccess, onError: onError)
    }
}

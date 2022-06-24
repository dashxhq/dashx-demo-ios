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
    
    static func loginUser(email: String, password: String, onSuccess: @escaping (NSDictionary?) -> Void, onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/login"
        let params: NSDictionary = [
            "email": email,
            "password": password
        ]
        
        network.makePostAPICall(path: path, params: params, onSuccess: onSuccess, onError: onError)
    }
    
    static func registerUser(firstName: String, lastName: String, email: String, password: String, onSuccess: @escaping (NSDictionary?) -> Void, onError: @escaping (NetworkError) -> Void) {
        // Prepare request parts
        let path = "/register"
        let params: NSDictionary = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": password
        ]
        
        network.makePostAPICall(path: path, httpMethod: "POST", params: params, onSuccess: onSuccess, onError: onError)
    }
}

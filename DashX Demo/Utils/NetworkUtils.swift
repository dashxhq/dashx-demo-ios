//
//  NetworkUtilities.swift
//  TestApp
//
//  Created by Ravindar Katkuri on 23/06/22.
//

import Foundation

class NetworkError {
    var statusCode: Int!
    var code: String?
    var message: String?
    var data: NSDictionary?
    
    init(statusCode: Int, message: String?, data: NSDictionary? = nil) {
        self.statusCode = statusCode
        self.message = message
    }
}

class NetworkUtils {
    private let baseURL: String!
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    private func getURL(atPath path: String) -> URL? {
        return URL(string: self.baseURL + path)
    }
    
    private func getURLRequest(httpMethod: String, url: URL, params: NSDictionary) -> URLRequest? {
        var request =  URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else { return nil }
        request.httpBody = httpBody
        
        return request
    }

    func makePostAPICall(path: String, httpMethod: String = "POST", params: NSDictionary, onSuccess: @escaping (NSDictionary?) -> Void, onError: @escaping (NetworkError) -> Void) {
        
        if let url = self.getURL(atPath: path), let request = getURLRequest(httpMethod: httpMethod, url: url, params: params) {
         
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
              if let error = error {
                print("Error with request: \(error)")
                onError(NetworkError(statusCode: 0, message: error.localizedDescription))
                return
              }
              
            let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.allowFragments]) as? NSDictionary
            let httpResponse = response as? HTTPURLResponse
                
            if (200...299).contains(httpResponse?.statusCode ?? 0) {
                onSuccess(jsonResponse)
            } else {
                print("Error with the response code, unexpected status code: \(httpResponse?.statusCode ?? 0)")
                onError(NetworkError(statusCode: httpResponse!.statusCode, message: jsonResponse?["message"] as? String ?? "", data: jsonResponse))
                return
            }
            })
            
            task.resume()
            
            
        } else {
            onError(NetworkError(statusCode: 0, message: "Invalid URL"))
        }
    }
}


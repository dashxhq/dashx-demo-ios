//
//  NetworkUtilities.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 23/06/22.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case put = "PUT"
}

class NetworkError {
    var statusCode: Int!
    var code: String?
    var message: String?
    var data: Data?
    
    init(statusCode: Int, message: String?, data: Data? = nil) {
        self.statusCode = statusCode
        self.message = message
        self.data = data
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
    
    private func getURLRequest(httpMethod: HttpMethod,
                               url: URL,
                               params: NSDictionary? = nil) -> URLRequest? {
        var request =  URLRequest(url: url)
        
        // Set bearer authentication header
        if let token = LocalStorage.instance.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = httpMethod.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let params = params {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params,
                                                             options: .prettyPrinted) else { return nil }
            request.httpBody = httpBody
        }
        return request
    }
    
    func makeAPICall<T: Decodable>(path: String,
                                   httpMethod: HttpMethod = .post,
                                   params: NSDictionary? = nil,
                                   onSuccess: @escaping (T?) -> Void,
                                   onError: @escaping (NetworkError) -> Void) {
        
        if let url = self.getURL(atPath: path),
           let request = getURLRequest(httpMethod: httpMethod, url: url, params: params) {
         
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
              if let error = error {
                  print("Error with request: \(error)")
                  return onError(NetworkError(statusCode: 0, message: error.localizedDescription))
              }
              
            let httpResponse = response as? HTTPURLResponse
                
            if (200...299).contains(httpResponse?.statusCode ?? 0) {
                if httpResponse?.statusCode == 204 {
                    return onSuccess(NoResponse() as? T)
                }
                let decodedModel = try? JSONDecoder().decode(T.self, from: data!)
                return onSuccess(decodedModel)
            } else {
                print("Error with the response. Status code: \(httpResponse?.statusCode ?? 0)")
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data!)
                return onError(NetworkError(statusCode: httpResponse!.statusCode,
                                     message: errorResponse?.message ?? "",
                                     data: data))
            }
            })
            
            task.resume()
                        
        } else {
            return onError(NetworkError(statusCode: 0, message: "Invalid URL"))
        }
    }
}

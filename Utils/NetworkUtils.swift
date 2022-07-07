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
    
    private func getURLRequest(httpMethod: String,
                               url: URL,
                               params: NSDictionary) -> URLRequest? {
        var request =  URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params,
                                                         options: .prettyPrinted) else { return nil }
        request.httpBody = httpBody
        return request
    }

    func makePostAPICall<T: Decodable>(path: String,
                                       httpMethod: String = "POST",
                                       params: NSDictionary,
                                       onSuccess: @escaping (T?) -> Void,
                                       onError: @escaping (NetworkError) -> Void) {
        
        if let url = self.getURL(atPath: path),
            let request = getURLRequest(httpMethod: httpMethod, url: url, params: params) {
         
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
              if let error = error {
                print("Error with request: \(error)")
                onError(NetworkError(statusCode: 0, message: error.localizedDescription))
                return
              }
              
            let httpResponse = response as? HTTPURLResponse
                
            if (200...299).contains(httpResponse?.statusCode ?? 0) {
                let decodedModel = try? JSONDecoder().decode(T.self, from: data!)
                onSuccess(decodedModel)
            } else {
                print("Error with the response. Status code: \(httpResponse?.statusCode ?? 0)")
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data!)
                onError(NetworkError(statusCode: httpResponse!.statusCode,
                                     message: errorResponse?.message ?? "",
                                     data: data))
                return
            }
            })
            
            task.resume()
                        
        } else {
            onError(NetworkError(statusCode: 0, message: "Invalid URL"))
        }
    }
}

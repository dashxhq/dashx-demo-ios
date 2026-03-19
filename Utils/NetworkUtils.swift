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

#if DEBUG
    private func redactedForLogging(_ object: Any) -> Any {
        // Redact common sensitive fields (passwords, tokens, secrets) in nested JSON-like structures.
        let sensitiveKeys: Set<String> = [
            "password", "token", "access_token", "refresh_token", "authorization",
            "api_key", "apikey", "secret", "client_secret"
        ]

        if let dict = object as? [String: Any] {
            var out: [String: Any] = [:]
            out.reserveCapacity(dict.count)
            for (k, v) in dict {
                if sensitiveKeys.contains(k.lowercased()) {
                    out[k] = "<redacted>"
                } else {
                    out[k] = redactedForLogging(v)
                }
            }
            return out
        }

        if let array = object as? [Any] {
            return array.map { redactedForLogging($0) }
        }

        return object
    }

    private func logRequest(_ request: URLRequest, params: NSDictionary?) {
        guard let url = request.url else { return }
        print("\n➡️ [HTTP] \(request.httpMethod ?? "—") \(url.absoluteString)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            var safeHeaders = headers
            if safeHeaders["Authorization"] != nil {
                safeHeaders["Authorization"] = "Bearer <redacted>"
            }
            print("➡️ [HTTP] headers: \(safeHeaders)")
        }

        if let params = params as? [String: Any] {
            let redacted = redactedForLogging(params)
            if let data = try? JSONSerialization.data(withJSONObject: redacted, options: [.prettyPrinted, .sortedKeys]),
               let body = String(data: data, encoding: .utf8) {
                print("➡️ [HTTP] body:\n\(body)")
            }
        }
    }

    private func logResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            print("⬅️ [HTTP] error: \(error.localizedDescription)")
            return
        }
        guard let http = response as? HTTPURLResponse else {
            print("⬅️ [HTTP] non-http response")
            return
        }
        print("⬅️ [HTTP] status: \(http.statusCode)")
        if let data = data, !data.isEmpty, let text = String(data: data, encoding: .utf8) {
            print("⬅️ [HTTP] response body:\n\(text)")
        }
    }
#endif

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

//#if DEBUG
//            logRequest(request, params: params)
//#endif

            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
              if let error = error {
                  print("Error with request: \(error)")
                  return onError(NetworkError(statusCode: 0, message: error.localizedDescription))
              }

//#if DEBUG
//              self.logResponse(data: data, response: response, error: error)
//#endif

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

//
//  LocalStorage.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 28/06/22.
//

import Foundation

enum LocalStorageKey: String {
    case user
    case dashXToken
}

class LocalStorage {
    static let instance = LocalStorage()
    
    private init() {}
    
    private let defaults = UserDefaults.standard
    
    private func getValue<T: Decodable>(forKey key: LocalStorageKey, as type: T.Type) -> T? {
        if let storedString = defaults.value(forKey: key.rawValue) as? String,
            let data = storedString.data(using: .utf8) {
            return try? JSONDecoder().decode(type, from: data)
            
        }
        
        return nil
    }
    
    private func setValue<T: Encodable>(forKey key: LocalStorageKey, value: T?) {
        if value == nil {
            defaults.removeObject(forKey: key.rawValue)
        } else if let data = try? JSONEncoder().encode(value), let jsonString = String(data: data, encoding: .utf8) {
            defaults.setValue(jsonString, forKey: key.rawValue)
            defaults.synchronize()
        }
    }
    
    func getUser() -> User? {
        return getValue(forKey: .user, as: User.self)
    }
    
    func setUser(_ value: User?) {
        setValue(forKey: .user, value: value)
    }
    
    func getDashXToken() -> String? {
        return getValue(forKey: .dashXToken, as: String.self)
    }
    
    func setDashXToken(_ value: String?) {
        setValue(forKey: .dashXToken, value: value)
    }
}

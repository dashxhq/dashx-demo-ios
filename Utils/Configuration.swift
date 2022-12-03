//
//  Configuration.swift
//  DashX Demo
//
//  Created by Pradeep Kumar on 04/12/22.
//

import Foundation

/// Simple class to get configuration values.
///
/// Learn more about this technique at [NSHipster](https://nshipster.com/xcconfig/#accessing-build-settings-from-swift).
enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

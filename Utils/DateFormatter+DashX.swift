//
//  DateFormatter+DashX.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 21/07/22.
//

import Foundation

extension DateFormatter {
    /// Format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static var fullDate: DateFormatter {
        struct Static {
            static let instance = DateFormatter()
        }
        Static.instance.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return Static.instance
    }
    
    /// Format: "dd MMM yy"
    static var briefDate: DateFormatter {
        struct Static {
            static let instance = DateFormatter()
        }
        Static.instance.dateFormat = "dd MMM yy"
        return Static.instance
    }
    
    // MARK: - Helpers
    func stringFromDate(_ date: Date) -> String {
        return self.string(from: date)
    }
    func dateFromString(_ date: String) -> Date? {
        return self.date(from: date)
    }
}

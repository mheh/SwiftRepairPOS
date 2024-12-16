//
//  Date.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/16/24.
//
import Foundation

extension Date {
    /// Format a date to ISO8601 formated string
    func iso8601FormattedString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter.string(from: self)
    }
}

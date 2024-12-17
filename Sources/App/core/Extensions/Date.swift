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


extension Date {
    /// When an optional date fails to initialize, provide this date
    func failedOptional() -> Date {
        // Why force unwrap here :(
        Calendar.current.date(from: DateComponents(year: 1970, month: 1, day: 1))!
    }
    
}

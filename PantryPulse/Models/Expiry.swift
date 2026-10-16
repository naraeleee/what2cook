import Foundation

enum ExpiryTone {
    case expired
    case soon
    case fresh
}

/// Everything about "how long until this goes off", kept free of UI so it is easy to test.
enum Expiry {
    /// Items with this many days left (or fewer) count as "expiring soon".
    static let soonThreshold = 3

    /// Whole calendar days from `now` until `date` (0 = today, negative = already expired).
    static func daysUntil(_ date: Date, from now: Date = Date(), calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    static func tone(daysLeft: Int) -> ExpiryTone {
        if daysLeft < 0 { return .expired }
        if daysLeft <= soonThreshold { return .soon }
        return .fresh
    }

    /// Short text for the pill. Urgent states use two lines so the pill stays compact.
    static func pillText(daysLeft: Int) -> String {
        switch tone(daysLeft: daysLeft) {
        case .expired:
            return "Expired"
        case .soon:
            switch daysLeft {
            case 0: return "Expires\ntoday"
            case 1: return "Expires\ntomorrow"
            default: return "Expires in\n\(daysLeft) days"
            }
        case .fresh:
            return "\(daysLeft) days left"
        }
    }
}

extension Date {
    /// Midnight today shifted by `days` (negative values go into the past).
    static func daysFromToday(_ days: Int, calendar: Calendar = .current) -> Date {
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: days, to: today) ?? today
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

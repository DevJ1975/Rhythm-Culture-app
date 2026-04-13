// Date+Extensions.swift
// Relative time display helpers.

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        switch seconds {
        case 0..<60:       return "just now"
        case 60..<3600:    return "\(seconds / 60)m ago"
        case 3600..<86400: return "\(seconds / 3600)h ago"
        default:           return "\(seconds / 86400)d ago"
        }
    }
}

extension Int {
    func shortFormatted() -> String {
        switch self {
        case 1_000_000...: return String(format: "%.1fM", Double(self) / 1_000_000)
        case 1_000...:     return String(format: "%.1fK", Double(self) / 1_000)
        default:           return "\(self)"
        }
    }
}

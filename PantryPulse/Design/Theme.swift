import SwiftUI

extension Color {
    /// `Color(hex: 0x4A6050)`
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// PantryPulse palette: fresh kitchen tones with amber for anything that needs attention.
enum Theme {
    // Surfaces
    static let background = Color(hex: 0xF7F5EF)
    static let card = Color(hex: 0xFDFCF9)
    static let inset = Color(hex: 0xF8F7F1)
    static let insetGreen = Color(hex: 0xF0F2EC)
    static let hairline = Color(hex: 0xE4E2D8)

    // Ink
    static let ink = Color(hex: 0x262C28)
    static let inkMuted = Color(hex: 0x7B837A)

    // Sage
    static let sage = Color(hex: 0x4A6050)
    static let sageSoft = Color(hex: 0xE6EDE6)
    static let sageInk = Color(hex: 0x5A6B5E)
    static let sageLight = Color(hex: 0xA9C4A5)
    static let badgeInk = Color(hex: 0x3F4D43)

    // Warm
    static let sand = Color(hex: 0xE8DFC8)
    static let tan = Color(hex: 0xE6CF9B)
    static let lavender = Color(hex: 0xC3B5CF)

    // Alerts
    static let amberFill = Color(hex: 0xF5DFC5)
    static let amberInk = Color(hex: 0x8A4B22)
    static let redFill = Color(hex: 0xF3D4CF)
    static let redInk = Color(hex: 0x9A3B2E)

    /// Deep green card used for the macro summary and remaining-budget cards.
    static let hero = LinearGradient(
        colors: [Color(hex: 0x4A5D50), Color(hex: 0x394A3E)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension FoodCategory {
    /// Tint of the initials tile for items in this category.
    var badgeFill: Color {
        switch self {
        case .protein: return Color(hex: 0xD9E2D9)
        case .carb: return Color(hex: 0xE8DFC8)
        case .produce: return Color(hex: 0xCFDCC4)
        case .fat: return Color(hex: 0xEBE0BC)
        case .beverage: return Color(hex: 0xD8E3E6)
        case .condiment: return Color(hex: 0xEBD9D2)
        }
    }
}

extension RecipeTone {
    var gradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .terracotta: colors = [Color(hex: 0xD6A78C), Color(hex: 0xB9806A)]
        case .sage: colors = [Color(hex: 0xA9B896), Color(hex: 0x7E9174)]
        case .sand: colors = [Color(hex: 0xDAC08B), Color(hex: 0xB09667)]
        case .slate: colors = [Color(hex: 0x93A6AB), Color(hex: 0x688085)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

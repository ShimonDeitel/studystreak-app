import SwiftUI

/// Bespoke palette for Studystreak: Log a daily study check-in and build a visible streak.
enum Theme {
    static let accent = Color(red: 1.000, green: 0.478, blue: 0.271)
    static let background = Color(red: 0.090, green: 0.059, blue: 0.043)
    static let card = Color(red: 0.141, green: 0.094, blue: 0.071)
    static let ink = Color(white: 0.95)
    static let mutedInk = Color(white: 0.65)

    static func titleFont(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func bodyFont(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    static func labelFont(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static let cornerRadius: CGFloat = 18
}

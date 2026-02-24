import SwiftUI

struct Item: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let price: Double
}

struct TaskItem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let completed: Bool
    let createdAt: Date
    let updatedAt: Date?

    var statusText: String { completed ? "Completed" : "Pending" }
}

struct HealthResponse: Codable {
    let status: String
}

// MARK: - Enums for Options Menu

enum CurrencyOption: String, CaseIterable, Identifiable {
    case usd = "USD"
    case gbp = "GBP"
    case eur = "EUR"
    case inr = "INR"
    case aed = "AED"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .gbp: return "\u{00A3}"
        case .eur: return "\u{20AC}"
        case .inr: return "\u{20B9}"
        case .aed: return "\u{062F}.\u{0625}"
        }
    }

    var displayName: String {
        "\(symbol) \(rawValue)"
    }
}

enum FontFamily: String, CaseIterable, Identifiable {
    case system = "System"
    case arial = "Arial"
    case helvetica = "Helvetica"
    case times = "Times New Roman"
    case courier = "Courier"

    var id: String { rawValue }
}

enum TextAlignmentOption: String, CaseIterable, Identifiable {
    case leading = "Left"
    case center = "Center"
    case trailing = "Right"

    var id: String { rawValue }

    var alignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    var frameAlignment: Alignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double((rgbValue & 0x0000FF)) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        guard let components = NSColor(self).usingColorSpace(.sRGB) else {
            return "#000000"
        }
        let r = Int(components.redComponent * 255)
        let g = Int(components.greenComponent * 255)
        let b = Int(components.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

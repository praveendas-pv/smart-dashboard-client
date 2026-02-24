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
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cny = "CNY"
    case inr = "INR"
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"
    case hkd = "HKD"
    case sgd = "SGD"
    case krw = "KRW"
    case nzd = "NZD"
    case sek = "SEK"
    case nok = "NOK"
    case dkk = "DKK"
    case zar = "ZAR"
    case brl = "BRL"
    case mxn = "MXN"
    case aed = "AED"
    case sar = "SAR"
    case thb = "THB"
    case twd = "TWD"
    case pln = "PLN"
    case `try` = "TRY"
    case idr = "IDR"
    case myr = "MYR"
    case php = "PHP"
    case czk = "CZK"
    case ils = "ILS"
    case clp = "CLP"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "\u{20AC}"
        case .gbp: return "\u{00A3}"
        case .jpy: return "\u{00A5}"
        case .cny: return "\u{00A5}"
        case .inr: return "\u{20B9}"
        case .aud: return "A$"
        case .cad: return "C$"
        case .chf: return "CHF"
        case .hkd: return "HK$"
        case .sgd: return "S$"
        case .krw: return "\u{20A9}"
        case .nzd: return "NZ$"
        case .sek: return "kr"
        case .nok: return "kr"
        case .dkk: return "kr"
        case .zar: return "R"
        case .brl: return "R$"
        case .mxn: return "MX$"
        case .aed: return "\u{062F}.\u{0625}"
        case .sar: return "\u{FDFC}"
        case .thb: return "\u{0E3F}"
        case .twd: return "NT$"
        case .pln: return "z\u{0142}"
        case .try: return "\u{20BA}"
        case .idr: return "Rp"
        case .myr: return "RM"
        case .php: return "\u{20B1}"
        case .czk: return "K\u{010D}"
        case .ils: return "\u{20AA}"
        case .clp: return "CL$"
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

    var isLight: Bool {
        guard let components = NSColor(self).usingColorSpace(.sRGB) else {
            return true
        }
        let luminance = 0.299 * components.redComponent + 0.587 * components.greenComponent + 0.114 * components.blueComponent
        return luminance > 0.5
    }
}

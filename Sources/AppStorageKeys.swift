import Foundation

enum AppStorageKeys {
    // Title
    static let dashboardTitle = "dashboardTitle"

    // Font formatting
    static let fontFamily = "fontFamily"
    static let fontSize = "fontSize"
    static let isBold = "fontBold"
    static let isItalic = "fontItalic"
    static let isUnderline = "fontUnderline"
    static let textColorHex = "textColorHex"
    static let textAlignment = "textAlignment"

    // Currency
    static let currencyCode = "currencyCode"

    // Background colors (separate per area)
    static let mainBgColorHex = "mainBgColorHex"
    static let tableBgColorHex = "tableBgColorHex"
    static let headerBgColorHex = "headerBgColorHex"

    // Sheet triggers
    static let showFontPanel = "showFontPanel"
    static let showTitleEditor = "showTitleEditor"
    static let showBgColorPanel = "showBgColorPanel"
}

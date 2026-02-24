import SwiftUI
import AppKit

@main
struct SmartDashboardApp: App {
    @AppStorage(AppStorageKeys.showFontPanel) private var showFontPanel = false
    @AppStorage(AppStorageKeys.showTitleEditor) private var showTitleEditor = false
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = "USD"

    init() {
        // Required for swift run to show GUI window
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        // Reset transient sheet triggers
        UserDefaults.standard.set(false, forKey: AppStorageKeys.showFontPanel)
        UserDefaults.standard.set(false, forKey: AppStorageKeys.showTitleEditor)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 400)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandMenu("Options") {
                Button("Font Settings...") {
                    showFontPanel = true
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])

                Divider()

                Menu("Currency") {
                    ForEach(CurrencyOption.allCases) { currency in
                        Button {
                            currencyCode = currency.rawValue
                        } label: {
                            if currencyCode == currency.rawValue {
                                Label(currency.displayName, systemImage: "checkmark")
                            } else {
                                Text(currency.displayName)
                            }
                        }
                    }
                }

                Divider()

                Button("Edit Title...") {
                    showTitleEditor = true
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}

import SwiftUI

struct FontSettingsView: View {
    @AppStorage(AppStorageKeys.fontFamily) private var fontFamily = FontFamily.system.rawValue
    @AppStorage(AppStorageKeys.fontSize) private var fontSize = 28.0
    @AppStorage(AppStorageKeys.isBold) private var isBold = true
    @AppStorage(AppStorageKeys.isItalic) private var isItalic = false
    @AppStorage(AppStorageKeys.isUnderline) private var isUnderline = false
    @AppStorage(AppStorageKeys.textColorHex) private var textColorHex = "#000000"
    @AppStorage(AppStorageKeys.textAlignment) private var textAlignment = TextAlignmentOption.leading.rawValue

    @Environment(\.dismiss) private var dismiss

    private var textColor: Binding<Color> {
        Binding(
            get: { Color(hex: textColorHex) },
            set: { textColorHex = $0.hexString }
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Font Settings")
                .font(.title2.bold())

            previewSection

            Divider()

            Form {
                Picker("Font Family", selection: $fontFamily) {
                    ForEach(FontFamily.allCases) { family in
                        Text(family.rawValue)
                            .tag(family.rawValue)
                    }
                }

                HStack {
                    Text("Font Size: \(Int(fontSize))pt")
                    Slider(value: $fontSize, in: 10...48, step: 1)
                }

                HStack(spacing: 12) {
                    Text("Style:")
                    Toggle(isOn: $isBold) {
                        Image(systemName: "bold")
                    }
                    .toggleStyle(.button)

                    Toggle(isOn: $isItalic) {
                        Image(systemName: "italic")
                    }
                    .toggleStyle(.button)

                    Toggle(isOn: $isUnderline) {
                        Image(systemName: "underline")
                    }
                    .toggleStyle(.button)
                }

                ColorPicker("Text Color", selection: textColor, supportsOpacity: false)

                Picker("Alignment", selection: $textAlignment) {
                    ForEach(TextAlignmentOption.allCases) { option in
                        Label(option.rawValue, systemImage: alignmentIcon(for: option))
                            .tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            .formStyle(.grouped)

            HStack {
                Button("Reset to Defaults") {
                    resetDefaults()
                }
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 450, height: 520)
    }

    private var previewSection: some View {
        let family = FontFamily(rawValue: fontFamily) ?? .system
        let alignOpt = TextAlignmentOption(rawValue: textAlignment) ?? .leading

        return Text("Preview Title Text")
            .font(resolvedFont(family: family, size: fontSize, bold: isBold, italic: isItalic))
            .underline(isUnderline)
            .foregroundStyle(Color(hex: textColorHex))
            .multilineTextAlignment(alignOpt.alignment)
            .frame(maxWidth: .infinity, alignment: alignOpt.frameAlignment)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary))
    }

    private func alignmentIcon(for option: TextAlignmentOption) -> String {
        switch option {
        case .leading: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .trailing: return "text.alignright"
        }
    }

    private func resetDefaults() {
        fontFamily = FontFamily.system.rawValue
        fontSize = 28.0
        isBold = true
        isItalic = false
        isUnderline = false
        textColorHex = "#000000"
        textAlignment = TextAlignmentOption.leading.rawValue
    }
}

func resolvedFont(family: FontFamily, size: Double, bold: Bool, italic: Bool) -> Font {
    switch family {
    case .system:
        var font = Font.system(size: size, weight: bold ? .bold : .regular)
        if italic { font = font.italic() }
        return font
    case .arial, .helvetica, .times, .courier:
        var font = Font.custom(family.rawValue, size: size)
        if bold { font = font.weight(.bold) }
        if italic { font = font.italic() }
        return font
    }
}

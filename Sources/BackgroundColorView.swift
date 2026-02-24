import SwiftUI

struct BackgroundColorView: View {
    @AppStorage(AppStorageKeys.bgColorHex) private var savedBgColorHex = "#FFFFFF"
    @AppStorage(AppStorageKeys.applyBgToMain) private var savedApplyToMain = true
    @AppStorage(AppStorageKeys.applyBgToTable) private var savedApplyToTable = true
    @AppStorage(AppStorageKeys.applyBgToHeader) private var savedApplyToHeader = false

    @Environment(\.dismiss) private var dismiss

    @State private var selectedHex = "#FFFFFF"
    @State private var applyToMain = true
    @State private var applyToTable = true
    @State private var applyToHeader = false

    private let presets: [(name: String, hex: String)] = [
        ("White", "#FFFFFF"),
        ("Light Gray", "#F5F5F5"),
        ("Dark", "#1E1E1E"),
        ("Light Blue", "#E3F2FD"),
        ("Light Green", "#E8F5E9"),
        ("Cream", "#FFF8E1"),
        ("Light Purple", "#F3E5F5"),
    ]

    private var customColor: Binding<Color> {
        Binding(
            get: { Color(hex: selectedHex) },
            set: { selectedHex = $0.hexString }
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Background Color")
                .font(.title2.bold())

            // Preview
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: selectedHex))
                .frame(height: 50)
                .overlay(
                    Text("Preview")
                        .foregroundStyle(Color(hex: selectedHex).isLight ? .black : .white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Divider()

            // Presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Presets:")
                    .font(.headline)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 10) {
                    ForEach(presets, id: \.hex) { preset in
                        Button {
                            selectedHex = preset.hex
                        } label: {
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: preset.hex))
                                    .frame(height: 36)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(selectedHex == preset.hex ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: selectedHex == preset.hex ? 2 : 1)
                                    )
                                    .overlay(
                                        Group {
                                            if selectedHex == preset.hex {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(Color(hex: preset.hex).isLight ? .black : .white)
                                            }
                                        }
                                    )
                                Text(preset.name)
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Custom color
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom:")
                    .font(.headline)
                ColorPicker("Pick Custom Color", selection: customColor, supportsOpacity: false)
            }

            Divider()

            // Apply to toggles
            VStack(alignment: .leading, spacing: 8) {
                Text("Apply to:")
                    .font(.headline)
                Toggle("Main background", isOn: $applyToMain)
                Toggle("Table background", isOn: $applyToTable)
                Toggle("Header only", isOn: $applyToHeader)
            }

            Spacer()

            // Actions
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Apply") {
                    savedBgColorHex = selectedHex
                    savedApplyToMain = applyToMain
                    savedApplyToTable = applyToTable
                    savedApplyToHeader = applyToHeader
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 520)
        .onAppear {
            selectedHex = savedBgColorHex
            applyToMain = savedApplyToMain
            applyToTable = savedApplyToTable
            applyToHeader = savedApplyToHeader
        }
    }
}

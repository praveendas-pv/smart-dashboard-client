import SwiftUI

struct BackgroundColorView: View {
    @AppStorage(AppStorageKeys.mainBgColorHex) private var savedMainBg = "#FFFFFF"
    @AppStorage(AppStorageKeys.tableBgColorHex) private var savedTableBg = "#F5F5F5"
    @AppStorage(AppStorageKeys.headerBgColorHex) private var savedHeaderBg = "#E0E0E0"

    @Environment(\.dismiss) private var dismiss

    @State private var mainBg = "#FFFFFF"
    @State private var tableBg = "#F5F5F5"
    @State private var headerBg = "#E0E0E0"

    private let themes: [(name: String, icon: String, main: String, table: String, header: String)] = [
        ("Light", "sun.max.fill", "#FFFFFF", "#F5F5F5", "#E0E0E0"),
        ("Dark", "moon.fill", "#1E1E1E", "#2D2D2D", "#3D3D3D"),
        ("Ocean", "water.waves", "#E3F2FD", "#BBDEFB", "#1976D2"),
        ("Forest", "leaf.fill", "#E8F5E9", "#C8E6C9", "#388E3C"),
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Background Colors")
                .font(.title2.bold())

            // Individual color pickers
            VStack(spacing: 12) {
                colorRow(label: "Main Background", hex: $mainBg)
                colorRow(label: "Table Background", hex: $tableBg)
                colorRow(label: "Header Background", hex: $headerBg)
            }

            Divider()

            // Quick Themes
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Themes:")
                    .font(.headline)

                HStack(spacing: 10) {
                    ForEach(themes, id: \.name) { theme in
                        Button {
                            mainBg = theme.main
                            tableBg = theme.table
                            headerBg = theme.header
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(hex: theme.main))
                                        .frame(height: 32)
                                    HStack(spacing: 2) {
                                        Circle().fill(Color(hex: theme.table)).frame(width: 10, height: 10)
                                        Circle().fill(Color(hex: theme.header)).frame(width: 10, height: 10)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isThemeSelected(theme) ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isThemeSelected(theme) ? 2 : 1)
                                )
                                Label(theme.name, systemImage: theme.icon)
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            // Preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Preview:")
                    .font(.headline)
                HStack(spacing: 4) {
                    previewSwatch("Main", hex: mainBg)
                    previewSwatch("Table", hex: tableBg)
                    previewSwatch("Header", hex: headerBg)
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Reset") {
                    mainBg = "#FFFFFF"
                    tableBg = "#F5F5F5"
                    headerBg = "#E0E0E0"
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Apply All") {
                    savedMainBg = mainBg
                    savedTableBg = tableBg
                    savedHeaderBg = headerBg
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 420)
        .fixedSize()
        .onAppear {
            mainBg = savedMainBg
            tableBg = savedTableBg
            headerBg = savedHeaderBg
        }
    }

    private func colorRow(label: String, hex: Binding<String>) -> some View {
        HStack {
            Text(label)
                .frame(width: 140, alignment: .leading)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: hex.wrappedValue))
                .frame(width: 30, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Text(hex.wrappedValue)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            Spacer()

            ColorPicker("", selection: Binding(
                get: { Color(hex: hex.wrappedValue) },
                set: { hex.wrappedValue = $0.hexString }
            ), supportsOpacity: false)
            .labelsHidden()
        }
    }

    private func previewSwatch(_ label: String, hex: String) -> some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: hex))
                .frame(height: 28)
                .overlay(
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(Color(hex: hex).isLight ? .black : .white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private func isThemeSelected(_ theme: (name: String, icon: String, main: String, table: String, header: String)) -> Bool {
        mainBg == theme.main && tableBg == theme.table && headerBg == theme.header
    }
}

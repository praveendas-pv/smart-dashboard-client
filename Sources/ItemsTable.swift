import SwiftUI

struct ItemsTable: View {
    let items: [Item]
    var currencyCode: String = "USD"
    var onEdit: ((Item) -> Void)?
    var onDelete: ((Int) -> Void)?

    @State private var itemToDelete: Item?
    @State private var hoveredItemId: Int?

    @AppStorage(AppStorageKeys.fontFamily) private var fontFamily = FontFamily.system.rawValue
    @AppStorage(AppStorageKeys.fontSize) private var fontSize = 28.0
    @AppStorage(AppStorageKeys.isBold) private var isBold = true
    @AppStorage(AppStorageKeys.isItalic) private var isItalic = false
    @AppStorage(AppStorageKeys.bgColorHex) private var bgColorHex = "#FFFFFF"
    @AppStorage(AppStorageKeys.applyBgToTable) private var applyBgToTable = true

    private let headerColor = Color(nsColor: NSColor.controlAccentColor)

    private var tableBgColor: Color {
        applyBgToTable ? Color(hex: bgColorHex) : Color(nsColor: .controlBackgroundColor)
    }

    private var smartTextColor: Color {
        applyBgToTable && !Color(hex: bgColorHex).isLight ? .white : .primary
    }

    private var smartSecondaryTextColor: Color {
        applyBgToTable && !Color(hex: bgColorHex).isLight ? .white.opacity(0.7) : .secondary
    }

    private var contentFont: Font {
        let family = FontFamily(rawValue: fontFamily) ?? .system
        let tableSize = max(12, min(fontSize * 0.5, 18))
        return resolvedFont(family: family, size: tableSize, bold: isBold, italic: isItalic)
    }

    private var headerFont: Font {
        let family = FontFamily(rawValue: fontFamily) ?? .system
        let tableSize = max(12, min(fontSize * 0.5, 18))
        return resolvedFont(family: family, size: tableSize, bold: true, italic: false)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                Text("#")
                    .font(headerFont)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)

                Text("Name")
                    .font(headerFont)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Description")
                    .font(headerFont)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Price")
                    .font(headerFont)
                    .frame(width: 100, alignment: .trailing)

                Text("")
                    .frame(width: 60)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(headerColor)

            // Content
            if items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No items yet. Add your first item above!")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("\(item.id)")
                                        .font(contentFont)
                                        .foregroundStyle(smartTextColor)
                                        .monospacedDigit()
                                        .frame(width: 60)
                                        .multilineTextAlignment(.center)

                                    Text(item.name)
                                        .font(contentFont)
                                        .foregroundStyle(smartTextColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(item.description)
                                        .font(contentFont)
                                        .foregroundStyle(smartSecondaryTextColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(item.price, format: .currency(code: currencyCode))
                                        .font(contentFont)
                                        .foregroundStyle(smartTextColor)
                                        .monospacedDigit()
                                        .frame(width: 100, alignment: .trailing)

                                    HStack(spacing: 6) {
                                        Button {
                                            onEdit?(item)
                                        } label: {
                                            Image(systemName: "pencil")
                                                .foregroundStyle(.blue)
                                        }
                                        .buttonStyle(.borderless)

                                        Button(role: .destructive) {
                                            itemToDelete = item
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundStyle(.red)
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                    .frame(width: 60)
                                }
                                .padding(.horizontal, 12)
                                .frame(minHeight: 44)
                                .background(rowBackground(index: index, itemId: item.id))
                                .onHover { isHovered in
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        hoveredItemId = isHovered ? item.id : nil
                                    }
                                }

                                if index < items.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Delete Item", isPresented: Binding(
            get: { itemToDelete != nil },
            set: { if !$0 { itemToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    onDelete?(item.id)
                    itemToDelete = nil
                }
            }
        } message: {
            if let item = itemToDelete {
                Text("Are you sure you want to delete \"\(item.name)\"?")
            }
        }
    }

    private func rowBackground(index: Int, itemId: Int) -> Color {
        if hoveredItemId == itemId {
            return Color.accentColor.opacity(0.15)
        }
        let baseColor = tableBgColor
        return index % 2 == 0 ? baseColor : baseColor.opacity(0.85)
    }
}

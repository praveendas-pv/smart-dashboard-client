import SwiftUI

struct ItemsTable: View {
    let items: [Item]
    var onEdit: ((Item) -> Void)?
    var onDelete: ((Int) -> Void)?

    @State private var itemToDelete: Item?

    var body: some View {
        Table(items) {
            TableColumn("ID") { item in
                Text("\(item.id)")
                    .monospacedDigit()
            }
            .width(50)

            TableColumn("Name", value: \.name)
                .width(min: 100, ideal: 150)

            TableColumn("Description", value: \.description)

            TableColumn("Price") { item in
                Text(item.price, format: .currency(code: "USD"))
                    .monospacedDigit()
            }
            .width(80)

            TableColumn("Actions") { item in
                HStack(spacing: 8) {
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
            }
            .width(80)
        }
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
}

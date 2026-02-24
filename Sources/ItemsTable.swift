import SwiftUI

struct ItemsTable: View {
    let items: [Item]
    var currencyCode: String = "USD"
    var onEdit: ((Item) -> Void)?
    var onDelete: ((Int) -> Void)?

    @State private var itemToDelete: Item?
    @State private var selection: Item.ID?

    var body: some View {
        Table(items, selection: $selection) {
            TableColumn("ID") { item in
                Text("\(item.id)")
                    .monospacedDigit()
                    .fontWeight(selection == item.id ? .bold : .regular)
            }
            .width(50)

            TableColumn("Name") { item in
                Text(item.name)
                    .fontWeight(selection == item.id ? .bold : .regular)
            }
            .width(min: 100, ideal: 150)

            TableColumn("Description") { item in
                Text(item.description)
                    .fontWeight(selection == item.id ? .bold : .regular)
            }

            TableColumn("Price") { item in
                Text(item.price, format: .currency(code: currencyCode))
                    .monospacedDigit()
                    .fontWeight(selection == item.id ? .bold : .regular)
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

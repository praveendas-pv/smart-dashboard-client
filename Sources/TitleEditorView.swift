import SwiftUI

struct TitleEditorView: View {
    @AppStorage(AppStorageKeys.dashboardTitle) private var dashboardTitle = "smart-dashboard"
    @Environment(\.dismiss) private var dismiss

    @State private var editingTitle = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Dashboard Title")
                .font(.title2.bold())

            TextField("Dashboard Title", text: $editingTitle)
                .textFieldStyle(.roundedBorder)
                .font(.title3)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    dashboardTitle = editingTitle
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(editingTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            editingTitle = dashboardTitle
        }
    }
}

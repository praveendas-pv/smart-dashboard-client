import SwiftUI

struct TasksTable: View {
    let tasks: [TaskItem]

    var body: some View {
        if tasks.isEmpty {
            emptyStateView
        } else {
            Table(tasks) {
                TableColumn("Title", value: \.title)
                    .width(min: 100, ideal: 150)

                TableColumn("Description") { task in
                    Text(task.description ?? "-")
                        .foregroundStyle(task.description == nil ? .tertiary : .primary)
                }

                TableColumn("Status") { task in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(task.completed ? .green : .orange)
                            .frame(width: 8, height: 8)
                        Text(task.statusText)
                    }
                }
                .width(100)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Tasks")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Tasks will appear here once created")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

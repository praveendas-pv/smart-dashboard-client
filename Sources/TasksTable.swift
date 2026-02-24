import SwiftUI

struct TasksTable: View {
    let tasks: [TaskItem]
    var onEdit: ((TaskItem) -> Void)?
    var onDelete: ((Int) -> Void)?

    @State private var taskToDelete: TaskItem?
    @State private var selection: TaskItem.ID?

    var body: some View {
        if tasks.isEmpty {
            emptyStateView
        } else {
            Table(tasks, selection: $selection) {
                TableColumn("Title") { task in
                    Text(task.title)
                        .fontWeight(selection == task.id ? .bold : .regular)
                }
                .width(min: 100, ideal: 150)

                TableColumn("Description") { task in
                    Text(task.description ?? "-")
                        .foregroundStyle(task.description == nil ? .tertiary : .primary)
                        .fontWeight(selection == task.id ? .bold : .regular)
                }

                TableColumn("Status") { task in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(task.completed ? .green : .orange)
                            .frame(width: 8, height: 8)
                        Text(task.statusText)
                            .fontWeight(selection == task.id ? .bold : .regular)
                    }
                }
                .width(100)

                TableColumn("Actions") { task in
                    HStack(spacing: 8) {
                        Button {
                            onEdit?(task)
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.borderless)

                        Button(role: .destructive) {
                            taskToDelete = task
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .width(80)
            }
            .alert("Delete Task", isPresented: Binding(
                get: { taskToDelete != nil },
                set: { if !$0 { taskToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    taskToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let task = taskToDelete {
                        onDelete?(task.id)
                        taskToDelete = nil
                    }
                }
            } message: {
                if let task = taskToDelete {
                    Text("Are you sure you want to delete \"\(task.title)\"?")
                }
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

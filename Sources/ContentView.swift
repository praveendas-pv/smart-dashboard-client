import SwiftUI

struct ContentView: View {
    @State private var items: [Item] = []
    @State private var tasks: [TaskItem] = []
    @State private var isLoading = false
    @State private var apiStatus = "Checking..."
    @State private var errorMessage: String?
    @State private var selectedTab = 0
    @State private var deleteError: String?
    @State private var showDeleteError = false
    @State private var itemToEdit: Item?
    @State private var taskToEdit: TaskItem?
    @State private var editItemName = ""
    @State private var editItemDescription = ""
    @State private var editItemPrice = ""
    @State private var editTaskTitle = ""
    @State private var editTaskDescription = ""
    @State private var editTaskCompleted = false
    @State private var newItemName = ""
    @State private var newItemDescription = ""
    @State private var newItemPrice = ""

    // Preferences
    @AppStorage(AppStorageKeys.dashboardTitle) private var dashboardTitle = "smart-dashboard"
    @AppStorage(AppStorageKeys.fontFamily) private var fontFamily = FontFamily.system.rawValue
    @AppStorage(AppStorageKeys.fontSize) private var fontSize = 28.0
    @AppStorage(AppStorageKeys.isBold) private var isBold = true
    @AppStorage(AppStorageKeys.isItalic) private var isItalic = false
    @AppStorage(AppStorageKeys.isUnderline) private var isUnderline = false
    @AppStorage(AppStorageKeys.textColorHex) private var textColorHex = "#000000"
    @AppStorage(AppStorageKeys.textAlignment) private var textAlignment = TextAlignmentOption.leading.rawValue
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = "USD"
    @AppStorage(AppStorageKeys.bgColorHex) private var bgColorHex = "#FFFFFF"
    @AppStorage(AppStorageKeys.applyBgToMain) private var applyBgToMain = true
    @AppStorage(AppStorageKeys.applyBgToTable) private var applyBgToTable = true
    @AppStorage(AppStorageKeys.applyBgToHeader) private var applyBgToHeader = false
    @AppStorage(AppStorageKeys.showFontPanel) private var showFontPanel = false
    @AppStorage(AppStorageKeys.showTitleEditor) private var showTitleEditor = false
    @AppStorage(AppStorageKeys.showBgColorPanel) private var showBgColorPanel = false

    private let baseURL = "http://localhost:8000"

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                let family = FontFamily(rawValue: fontFamily) ?? .system
                let alignOpt = TextAlignmentOption(rawValue: textAlignment) ?? .leading

                Text(dashboardTitle)
                    .font(resolvedFont(family: family, size: fontSize, bold: isBold, italic: isItalic))
                    .underline(isUnderline)
                    .foregroundStyle(Color(hex: textColorHex))
                    .multilineTextAlignment(alignOpt.alignment)
                    .frame(maxWidth: .infinity, alignment: alignOpt.frameAlignment)

                Spacer()
                Circle()
                    .fill(apiStatus == "healthy" ? .green : .red)
                    .frame(width: 12, height: 12)
                Text(apiStatus)
                    .foregroundStyle(applyBgToHeader && !Color(hex: bgColorHex).isLight ? .white.opacity(0.7) : .secondary)
            }
            .padding()
            .background(applyBgToHeader ? Color(hex: bgColorHex) : Color(nsColor: .windowBackgroundColor))

            Divider()

            // Content
            if let error = errorMessage {
                errorView(error: error)
            } else if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TabView(selection: $selectedTab) {
                    VStack(spacing: 0) {
                        HStack {
                            TextField("Name", text: $newItemName)
                                .textFieldStyle(.roundedBorder)
                            TextField("Description", text: $newItemDescription)
                                .textFieldStyle(.roundedBorder)
                            TextField("Price", text: $newItemPrice)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Button("Add") {
                                Task { await createItem() }
                            }
                            .disabled(newItemName.isEmpty)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)

                        Divider()

                        ItemsTable(items: items, currencyCode: currencyCode, onEdit: { item in
                            editItemName = item.name
                            editItemDescription = item.description
                            editItemPrice = String(item.price)
                            itemToEdit = item
                        }, onDelete: { id in
                            Task { await deleteItem(id: id) }
                        })
                    }
                        .tabItem {
                            Label("Items", systemImage: "shippingbox")
                        }
                        .tag(0)

                    TasksTable(tasks: tasks, onEdit: { task in
                        editTaskTitle = task.title
                        editTaskDescription = task.description ?? ""
                        editTaskCompleted = task.completed
                        taskToEdit = task
                    }, onDelete: { id in
                        Task { await deleteTask(id: id) }
                    })
                        .tabItem {
                            Label("Tasks", systemImage: "checklist")
                        }
                        .tag(1)
                }
            }
        }
        .background(applyBgToMain ? Color(hex: bgColorHex) : Color.clear)
        .task {
            await loadData()
        }
        .alert("Delete Failed", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteError ?? "Unknown error")
        }
        .sheet(item: $itemToEdit) { item in
            VStack(spacing: 16) {
                Text("Edit Item")
                    .font(.title2.bold())
                Form {
                    TextField("Name", text: $editItemName)
                    TextField("Description", text: $editItemDescription)
                    TextField("Price", text: $editItemPrice)
                }
                HStack {
                    Button("Cancel") {
                        itemToEdit = nil
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("Save") {
                        Task {
                            await updateItem(
                                id: item.id,
                                name: editItemName,
                                description: editItemDescription,
                                price: Double(editItemPrice) ?? item.price
                            )
                            itemToEdit = nil
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
            .frame(width: 400)
        }
        .sheet(item: $taskToEdit) { task in
            VStack(spacing: 16) {
                Text("Edit Task")
                    .font(.title2.bold())
                Form {
                    TextField("Title", text: $editTaskTitle)
                    TextField("Description", text: $editTaskDescription)
                    Toggle("Completed", isOn: $editTaskCompleted)
                }
                HStack {
                    Button("Cancel") {
                        taskToEdit = nil
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("Save") {
                        Task {
                            await updateTask(
                                id: task.id,
                                title: editTaskTitle,
                                description: editTaskDescription,
                                completed: editTaskCompleted
                            )
                            taskToEdit = nil
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
            .frame(width: 400)
        }
        .sheet(isPresented: $showFontPanel) {
            FontSettingsView()
        }
        .sheet(isPresented: $showTitleEditor) {
            TitleEditorView()
        }
        .sheet(isPresented: $showBgColorPanel) {
            BackgroundColorView()
        }
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(error)
                .foregroundStyle(.secondary)
            Text("Start API: cd services/api && uv run fastapi dev")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Button("Retry") {
                Task {
                    await loadData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil

        // Check health
        do {
            let url = URL(string: "\(baseURL)/health")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let health = try JSONDecoder().decode(HealthResponse.self, from: data)
            apiStatus = health.status
        } catch {
            apiStatus = "offline"
            errorMessage = "API not running"
            isLoading = false
            return
        }

        // Fetch items and tasks in parallel
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await loadItems() }
            group.addTask { await loadTasks() }
        }

        isLoading = false
    }

    private func loadItems() async {
        do {
            let url = URL(string: "\(baseURL)/items")!
            let (data, _) = try await URLSession.shared.data(from: url)
            items = try JSONDecoder().decode([Item].self, from: data)
        } catch {
            // Items loading failure is not critical
            print("Failed to load items: \(error)")
        }
    }

    private func loadTasks() async {
        do {
            let url = URL(string: "\(baseURL)/tasks")!

            // Create a custom URLSession with 5-second timeout
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 5
            let session = URLSession(configuration: config)

            let (data, _) = try await session.data(from: url)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            tasks = try decoder.decode([TaskItem].self, from: data)
        } catch {
            // Tasks loading failure is not critical
            print("Failed to load tasks: \(error)")
        }
    }

    private func createItem() async {
        do {
            let url = URL(string: "\(baseURL)/items")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "name": newItemName,
                "description": newItemDescription,
                "price": Double(newItemPrice) ?? 0.0
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 else {
                throw URLError(.badServerResponse)
            }

            let created = try JSONDecoder().decode(Item.self, from: data)
            items.append(created)

            newItemName = ""
            newItemDescription = ""
            newItemPrice = ""
        } catch {
            deleteError = "Failed to create item: \(error.localizedDescription)"
            showDeleteError = true
        }
    }

    private func deleteItem(id: Int) async {
        do {
            let url = URL(string: "\(baseURL)/items/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 204 else {
                throw URLError(.badServerResponse)
            }

            items.removeAll { $0.id == id }
        } catch {
            deleteError = "Failed to delete item: \(error.localizedDescription)"
            showDeleteError = true
        }
    }

    private func deleteTask(id: Int) async {
        do {
            let url = URL(string: "\(baseURL)/tasks/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 204 else {
                throw URLError(.badServerResponse)
            }

            tasks.removeAll { $0.id == id }
        } catch {
            deleteError = "Failed to delete task: \(error.localizedDescription)"
            showDeleteError = true
        }
    }

    private func updateItem(id: Int, name: String, description: String, price: Double) async {
        do {
            let url = URL(string: "\(baseURL)/items/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = ["name": name, "description": description, "price": price]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let updated = try JSONDecoder().decode(Item.self, from: data)
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = updated
            }
        } catch {
            deleteError = "Failed to update item: \(error.localizedDescription)"
            showDeleteError = true
        }
    }

    private func updateTask(id: Int, title: String, description: String, completed: Bool) async {
        do {
            let url = URL(string: "\(baseURL)/tasks/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = ["title": title, "description": description, "completed": completed]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            let updated = try decoder.decode(TaskItem.self, from: data)
            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index] = updated
            }
        } catch {
            deleteError = "Failed to update task: \(error.localizedDescription)"
            showDeleteError = true
        }
    }
}

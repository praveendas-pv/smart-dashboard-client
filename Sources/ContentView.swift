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

    private let baseURL = "http://localhost:8000"

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("smart-dashboard")
                    .font(.title.bold())
                Spacer()
                Circle()
                    .fill(apiStatus == "healthy" ? .green : .red)
                    .frame(width: 12, height: 12)
                Text(apiStatus)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.bar)

            Divider()

            // Content
            if let error = errorMessage {
                errorView(error: error)
            } else if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TabView(selection: $selectedTab) {
                    ItemsTable(items: items, onDelete: { id in
                        Task { await deleteItem(id: id) }
                    })
                        .tabItem {
                            Label("Items", systemImage: "shippingbox")
                        }
                        .tag(0)

                    TasksTable(tasks: tasks, onDelete: { id in
                        Task { await deleteTask(id: id) }
                    })
                        .tabItem {
                            Label("Tasks", systemImage: "checklist")
                        }
                        .tag(1)
                }
            }
        }
        .task {
            await loadData()
        }
        .alert("Delete Failed", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteError ?? "Unknown error")
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
}

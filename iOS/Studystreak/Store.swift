import Foundation
import Combine

@MainActor
final class StudystreakStore: ObservableObject {
    @Published private(set) var items: [StudystreakItem] = []
    @Published var isPro: Bool = false

    /// Free-tier cap. Deliberately set well above the seed-data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 20

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("studystreak_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Self.freeLimit
    }

    func add(title: String, category: String, value: Double, notes: String = "") -> Bool {
        guard canAddMore else { return false }
        let item = StudystreakItem(title: title, category: category, value: value, notes: notes)
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: StudystreakItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: StudystreakItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func toggleResolved(_ item: StudystreakItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isResolved.toggle()
        save()
    }

    var totalValue: Double {
        items.reduce(0) { $0 + $1.value }
    }

    func total(for category: String) -> Double {
        items.filter { $0.category == category }.reduce(0) { $0 + $1.value }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([StudystreakItem].self, from: data) else {
            items = Self.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [StudystreakItem] {
        [
        StudystreakItem(title: "Morning review", category: "Review", value: 25.0),
        StudystreakItem(title: "Practice set", category: "Practice", value: 40.0)
        ]
    }
}

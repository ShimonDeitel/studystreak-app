import Foundation

struct StudystreakItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var category: String
    var value: Double
    var date: Date = Date()
    var notes: String = ""
    var isResolved: Bool = false
}

enum StudystreakCategory: String, CaseIterable, Codable {
        case reading = "Reading"
    case practice = "Practice"
    case review = "Review"
    case flashcards = "Flashcards"
}

import Foundation

struct Payment: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), amount: Double, date: Date, notes: String = "") {
        self.id = id
        self.amount = amount
        self.date = date
        self.notes = notes
    }
}


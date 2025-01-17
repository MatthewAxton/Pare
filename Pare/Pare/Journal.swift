import UIKit
import FirebaseFirestoreSwift

class JournalPlant: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var soil: String?
    var fertilizer: String?
    var lastFertilized: Date?
    var notes: String?
    var imageUrl: String?
    var wateringRecords: [Date]?

    enum CodingKeys: String, CodingKey {
        case id, name, soil, fertilizer, lastFertilized, notes, imageUrl, wateringRecords
    }

    init(id: String? = nil, name: String, soil: String, fertilizer: String, lastFertilized: Date, notes: String, imageUrl: String, wateringRecords: [Date]) {
        self.id = id
        self.name = name
        self.soil = soil
        self.fertilizer = fertilizer
        self.lastFertilized = lastFertilized
        self.notes = notes
        self.imageUrl = imageUrl
        self.wateringRecords = wateringRecords
    }
}

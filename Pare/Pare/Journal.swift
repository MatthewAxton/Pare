import UIKit
import FirebaseFirestoreSwift

class Plant: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var soil: String?
    var fertilizer: String?
    var lastFertilized: Date?
    var notes: String?
    var imageUrl: String?
    var wateringRecords: [Date]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case soil
        case fertilizer
        case lastFertilized
        case notes
        case imageUrl
        case wateringRecords
    }
}




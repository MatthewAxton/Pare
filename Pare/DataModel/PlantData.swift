import UIKit

class PlantData: NSObject, Codable {
    var id: Int?
    var commonName: String?
    var scientificName: [String]?
    var otherNames: [String]?
    var cycle: String?
    var watering: String?
    var sunlight: [String]?
    var defaultImage: DefaultImage?

    private enum CodingKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case otherNames = "other_name"
        case cycle
        case watering
        case sunlight
        case defaultImage = "default_image"
    }

    struct DefaultImage: Codable {
        let license: Int?
        let licenseName: String?
        let licenseURL: String?
        let originalURL: String?
        let regularURL: String?
        let mediumURL: String?
        let smallURL: String?
        let thumbnail: String?

        enum CodingKeys: String, CodingKey {
            case license
            case licenseName = "license_name"
            case licenseURL = "license_url"
            case originalURL = "original_url"
            case regularURL = "regular_url"
            case mediumURL = "medium_url"
            case smallURL = "small_url"
            case thumbnail
        }
    }
}

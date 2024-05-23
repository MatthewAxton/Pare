import UIKit

class PlantData: NSObject, Decodable {
    var id: Int?
    var commonName: String?
    var scientificName: [String]?
    var otherNames: [String]?
    var cycle: String?
    var watering: String?
    var sunlight: [String]?
    var defaultImage: DefaultImage?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PlantKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        commonName = try container.decodeIfPresent(String.self, forKey: .commonName)
        scientificName = try container.decodeIfPresent([String].self, forKey: .scientificName)
        otherNames = try container.decodeIfPresent([String].self, forKey: .otherName)
        cycle = try container.decodeIfPresent(String.self, forKey: .cycle)
        watering = try container.decodeIfPresent(String.self, forKey: .watering)
        sunlight = try container.decodeIfPresent([String].self, forKey: .sunlight)
        defaultImage = try container.decodeIfPresent(DefaultImage.self, forKey: .defaultImage)
    }

    private enum PlantKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case otherName = "other_name"
        case cycle
        case watering
        case sunlight
        case defaultImage = "default_image"
    }

    struct DefaultImage: Decodable {
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

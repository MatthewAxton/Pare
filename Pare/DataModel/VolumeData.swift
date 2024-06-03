//
//  VolumeData.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 23/5/2024.
//

import UIKit

class VolumeData: NSObject, Decodable {
    var plants: [PlantData]?

    private enum CodingKeys: String, CodingKey {
        case plants = "data"
    }
    
    

}

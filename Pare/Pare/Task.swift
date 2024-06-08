//
//  Task.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 8/6/2024.
//

import Foundation
import FirebaseFirestore

class Task: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var isCompleted: Bool?
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, isCompleted, date
    }
    
    init(id: String? = nil, name: String, isCompleted: Bool, date: Date) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.date = date
    }
}

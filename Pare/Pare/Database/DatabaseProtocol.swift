//
//  DatahaseProtocol.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 3/6/2024.
//


import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType { get set }
    func onAllPlantsChange(change: DatabaseChange, plants: [Plant])
}

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case plants
    case all
}

protocol DatabaseProtocol: AnyObject
{
    func cleanup()
    func addPlant(name: String, soil: String, fertilizer: String, lastFertilized: Date, notes: String, image: UIImage, wateringRecords: [Date], completion: @escaping (Error?) -> Void)
    func fetchPlants(completion: @escaping ([Plant]?, Error?) -> Void)
    func searchPlants(query: String, completion: @escaping ([Plant]?, Error?) -> Void)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}

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
    func onAllPlantsChange(change: DatabaseChange, plants: [JournalPlant])
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
    func fetchPlants(completion: @escaping ([JournalPlant]?, Error?) -> Void)
    func searchPlants(query: String, completion: @escaping ([JournalPlant]?, Error?) -> Void)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func fetchTasks(completion: @escaping ([Task]?, Error?) -> Void)
   func addTask(_ task: Task, completion: @escaping (Error?) -> Void)
   func completeTask(_ task: Task, completion: @escaping (Error?) -> Void)
}

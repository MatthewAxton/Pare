//
//  FirebaseController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 3/6/2024.
//



import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class FirebaseController: NSObject, DatabaseProtocol {
    func cleanup() {

    }
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var plantList: [Plant] = []

    override init() {
        // Initialize Firebase and Firestore database
        
        database = Firestore.firestore()
        plantList = [Plant]()

        super.init()

        self.setupPlantListener()
    }

    var database: Firestore
    var plantsRef: CollectionReference?

    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onAllPlantsChange(change: .update, plants: plantList)
    }

    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }

    func addPlant(name: String, soil: String, fertilizer: String, lastFertilized: Date, notes: String, image: UIImage, wateringRecords: [Date], completion: @escaping (Error?) -> Void) {
        let plantId = UUID().uuidString
        let imageRef = Storage.storage().reference().child("plants/\(plantId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
            return
        }

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(error)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }

                guard let url = url else {
                    completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"]))
                    return
                }

                let plant = Plant(
                    id: plantId,
                    name: name,
                    soil: soil,
                    fertilizer: fertilizer,
                    lastFertilized: lastFertilized,
                    notes: notes,
                    imageUrl: url.absoluteString,
                    wateringRecords: wateringRecords
                )

                do {
                    try self.database.collection("plants").document(plantId).setData(from: plant) { error in
                        completion(error)
                    }
                } catch let error {
                    completion(error)
                }
            }
        }
    }

    func fetchPlants(completion: @escaping ([Plant]?, Error?) -> Void) {
        database.collection("plants").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let plants = documents.compactMap { doc -> Plant? in
                return try? doc.data(as: Plant.self)
            }
            completion(plants, nil)
        }
    }

    func searchPlants(query: String, completion: @escaping ([Plant]?, Error?) -> Void) {
        database.collection("plants").whereField("name", isGreaterThanOrEqualTo: query).whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let plants = documents.compactMap { doc -> Plant? in
                return try? doc.data(as: Plant.self)
            }
            completion(plants, nil)
        }
    }

    func setupPlantListener() {
        plantsRef = database.collection("plants")
        plantsRef?.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parsePlantsSnapshot(snapshot: querySnapshot)
        }
    }

    func parsePlantsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            var plant: Plant
            do {
                plant = try change.document.data(as: Plant.self)
            } catch {
                fatalError("Unable to decode plant: \(error.localizedDescription)")
            }

            if change.type == .added {
                plantList.insert(plant, at: Int(change.newIndex))
            } else if change.type == .modified {
                plantList.remove(at: Int(change.oldIndex))
                plantList.insert(plant, at: Int(change.newIndex))
            } else if change.type == .removed {
                plantList.remove(at: Int(change.oldIndex))
            }

            listeners.invoke { listener in
                listener.onAllPlantsChange(change: .update, plants: plantList)
            }
        }
    }
}

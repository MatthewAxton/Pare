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
    
    func addPlant(name: String, soil: String, fertilizer: String, lastFertilized: Date, notes: String, image: UIImage, wateringRecords: [Date], completion: @escaping ((any Error)?) -> Void) {
        let plantRef = database.collection("plants").document()
        let plantId = plantRef.documentID
        
        let plant = JournalPlant(
            id: plantId,
            name: name,
            soil: soil,
            fertilizer: fertilizer,
            lastFertilized: lastFertilized,
            notes: notes,
            imageUrl: "",
            wateringRecords: wateringRecords
        )

        do {
            try plantRef.setData(from: plant) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var plantList: [JournalPlant] = []
    var database: Firestore
    var plantsRef: CollectionReference?

    override init() {

        database = Firestore.firestore()
        plantsRef = database.collection("plants")
        plantList = []

        super.init()

        self.setupPlantListener()
    }

    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onAllPlantsChange(change: .update, plants: plantList)
    }

    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }

 
    func fetchPlants(completion: @escaping ([JournalPlant]?, Error?) -> Void) {
        database.collection("plants").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let plants = documents.compactMap { doc -> JournalPlant? in
                return try? doc.data(as: JournalPlant.self)
            }
            completion(plants, nil)
        }
    }

    func searchPlants(query: String, completion: @escaping ([JournalPlant]?, Error?) -> Void) {
        database.collection("plants").whereField("name", isGreaterThanOrEqualTo: query).whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let plants = documents.compactMap { doc -> JournalPlant? in
                return try? doc.data(as: JournalPlant.self)
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
            var plant: JournalPlant
            do {
                plant = try change.document.data(as: JournalPlant.self)
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

    // Upload image to Firebase Storage and get URL
    func uploadImage(_ image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        let plantId = UUID().uuidString
        let imageRef = Storage.storage().reference().child("plants/\(plantId).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
            return
        }

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let url = url else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"]))
                    return
                }

                completion(url.absoluteString, nil)
            }
        }
    }
}

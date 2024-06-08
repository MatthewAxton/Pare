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
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var plantList: [JournalPlant] = []
    var taskList: [Task] = []
    var database: Firestore
    var plantsRef: CollectionReference?
    var tasksRef: CollectionReference?
    
    override init() {
        database = Firestore.firestore()
        plantsRef = database.collection("plants")
        tasksRef = database.collection("tasks")
        plantList = []
        taskList = []
        super.init()
        self.setupPlantListener()
    }
    
    func cleanup() {}
    
    // MARK: - Plants
    
    func addPlant(name: String, soil: String, fertilizer: String, lastFertilized: Date, notes: String, image: UIImage, wateringRecords: [Date], completion: @escaping ((any Error)?) -> Void) {
        uploadImage(image) { imageUrl, error in
            guard let imageUrl = imageUrl, error == nil else {
                completion(error)
                return
            }
            
            let plantRef = self.database.collection("plants").document()
            let plantId = plantRef.documentID
            
            let plant = JournalPlant(
                id: plantId,
                name: name,
                soil: soil,
                fertilizer: fertilizer,
                lastFertilized: lastFertilized,
                notes: notes,
                imageUrl: imageUrl,
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
    
    // MARK: - Tasks
    
    func fetchTasks(completion: @escaping ([Task]?, Error?) -> Void) {
        database.collection("tasks").getDocuments { snapshot, error in
             if let error = error {
                 print("Error fetching tasks from Firebase: \(error)")
                 completion(nil, error)
                 return
             }

             guard let documents = snapshot?.documents else {
                 print("No tasks found in Firebase.")
                 completion([], nil)
                 return
             }

             let tasks = documents.compactMap { doc -> Task? in
                 return try? doc.data(as: Task.self)
             }
             print("Tasks fetched from Firebase: \(tasks.count)")
             completion(tasks, nil)
         }
    }
    
    func addTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        do {
            let _ = try tasksRef?.addDocument(from: task, completion: completion)
        } catch let error {
            completion(error)
        }
    }
    
    func completeTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        var updatedTask = task
        updatedTask.isCompleted = true
        
        do {
            try tasksRef?.document(task.id ?? "").setData(from: updatedTask) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onAllPlantsChange(change: .update, plants: plantList)
    }

    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}






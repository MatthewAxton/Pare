//
//  AddPlantDetailViewController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 6/6/2024.
//

import UIKit

class AddPlantDetailViewController: UIViewController {
    @IBOutlet weak var commonNameLabel: UILabel!
    
    @IBOutlet weak var scientificNameLabel: UILabel!
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    
    @IBOutlet weak var saveButton: UIButton!
    
    var plant: PlantData?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        displayPlantDetails()
    }
    
    func displayPlantDetails() {
        guard let plant = plant else { return }
        commonNameLabel.text = plant.commonName
        scientificNameLabel.text = plant.scientificName?.joined(separator: ", ")
        if let imageUrl = plant.defaultImage?.originalURL, let url = URL(string: imageUrl) {
            downloadImage(from: url)
        }
    }
    
    func downloadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.plantImageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let plant = plant else { return }
        
        // Safely unwrap optional values
        let commonName = plant.commonName ?? "Unknown"
        let soil = "Soil type here"  // This is a placeholder, replace with actual value if needed
        let fertilizer = "Fertilizer info here"  // This is a placeholder, replace with actual value if needed
        let imageUrl = plant.defaultImage?.originalURL ?? ""
        let lastFertilized = Date()  // Placeholder, replace with actual value if needed
        let notes = "Additional notes here"  // Placeholder, replace with actual value if needed
        
        let newPlant = Plant(
            id: UUID().uuidString,
            name: commonName,
            soil: soil,
            fertilizer: fertilizer,
            lastFertilized: lastFertilized,
            notes: notes,
            imageUrl: imageUrl,
            wateringRecords: []
        )
        
        databaseController?.addPlant(
            name: newPlant.name!,
            soil: newPlant.soil!,
            fertilizer: newPlant.fertilizer!,
            lastFertilized: newPlant.lastFertilized!,
            notes: newPlant.notes!,
            image: plantImageView.image ?? UIImage(),
            wateringRecords: []
        ) { error in
            if let error = error {
                print("Error adding plant: \(error)")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

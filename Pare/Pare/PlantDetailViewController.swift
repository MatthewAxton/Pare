//
//  PlantDetailViewController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 23/5/2024.
//

import UIKit

class PlantDetailViewController: UIViewController {

    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var commonNameLabel: UILabel!
    

    @IBOutlet weak var scientificNameLabel: UILabel!
    
    @IBOutlet weak var sunlightLabel: UILabel!
    @IBOutlet weak var wateringLabel: UILabel!
    @IBOutlet weak var cycleLabel: UILabel!
    
    var plant: PlantData?
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPlantDetails()
        

        // Do any additional setup after loading the view.
    }
    
    func displayPlantDetails() {
            guard let plant = plant else { return }
            commonNameLabel.text = plant.commonName
            scientificNameLabel.text = plant.scientificName?.joined(separator: ", ")
           
            cycleLabel.text = plant.cycle
            wateringLabel.text = plant.watering
            sunlightLabel.text = plant.sunlight?.joined(separator: ", ")

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

    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



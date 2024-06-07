//
//  JournalViewController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 1/6/2024.
//


import UIKit

class JournalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var journalCollectionView: UICollectionView!
    var plants: [Plant] = []
    let databaseService: DatabaseProtocol = FirebaseController()

    override func viewDidLoad() {
        super.viewDidLoad()

        journalCollectionView.dataSource = self
        journalCollectionView.delegate = self

        fetchPlants()
    }

    func fetchPlants() {
        databaseService.fetchPlants { plants, error in
            if let error = error {
                print("Error fetching plants: \(error)")
                return
            }

            self.plants = plants ?? []
            self.journalCollectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plants.count + 1 // Extra cell for adding a new plant
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == plants.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCollectionViewCell", for: indexPath)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCollectionViewCell", for: indexPath) as? journalCollectionViewCell else {
                return UICollectionViewCell()
            }
            let plant = plants[indexPath.row]
            cell.journalLabel.text = plant.name
            
            if let imageUrl = plant.imageUrl, let url = URL(string: imageUrl) {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.journalPhoto.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == plants.count {
            performSegue(withIdentifier: "addPlantSegue", sender: self)
        }
    }
}

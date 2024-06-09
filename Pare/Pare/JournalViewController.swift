//
//  JournalViewController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 1/6/2024.
//


import UIKit

class JournalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AddPlantDelegate {
    
    private let desiredImageSize = CGSize(width: 300, height: 300)
    
    @IBOutlet weak var journalCollectionView: UICollectionView!
    var plants: [JournalPlant] = []
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
             print("Fetched plants: \(self.plants)")
             self.journalCollectionView.reloadData()
         }
     }

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return plants.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCollectionViewCell", for: indexPath) as? journalCollectionViewCell else {
             return UICollectionViewCell()
         }
         
         let plant = plants[indexPath.row]
         cell.journalLabel.text = plant.name
         
         if let imageUrl = plant.imageUrl, let url = URL(string: imageUrl) {
             URLSession.shared.dataTask(with: url) { data, _, error in
                 if let data = data {
                     if let image = UIImage(data: data) {
                         let resizedImage = self.resizeImage(image, targetSize: self.desiredImageSize)
                         cell.journalPhoto.image = resizedImage
                         
                     }
                 }
             }.resume()
         }

         return cell
     }

     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         performSegue(withIdentifier: "addPlantSegue", sender: self)
     }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "addPlantSegue",
            let destinationVC = segue.destination as? AddPlantViewController {
             destinationVC.delegate = self
         }
     }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }

     // MARK: - AddPlantDelegate
     func didAddPlant(_ plant: JournalPlant) {
         plants.append(plant)
         print("Added plant: \(plant)")
         journalCollectionView.reloadData()
     }
 }

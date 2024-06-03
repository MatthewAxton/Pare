//
//  JournalViewController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 1/6/2024.
//

import UIKit

class JournalViewController: UIViewController {

    @IBOutlet weak var journalCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journalCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    }

extension JournalViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        <#code#>
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
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

}

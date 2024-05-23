import UIKit

class SearchPlantsTableViewController: UITableViewController, UISearchBarDelegate {
    
    let CELL_PLANT = "plantCell"
    let REQUEST_STRING = "https://perenual.com/api/species-list?key=sk-CPrZ664ea22fa60605611&q="
    var newPlants = [PlantData]()
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the navigation bar is visible
        navigationController?.navigationBar.isHidden = false
        
        // Set up search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Plants"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Register the cell identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_PLANT)
        
        // Set up indicator
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newPlants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_PLANT, for: indexPath)
        let plant = newPlants[indexPath.row]
        cell.textLabel?.text = plant.commonName
        cell.detailTextLabel?.text = plant.scientificName?.joined(separator: ", ")
        return cell
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        newPlants.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        Task {
            await requestPlantsNamed(searchText)
        }
    }

    func requestPlantsNamed(_ plantName: String) async {
        guard let queryString = plantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let requestURL = URL(string: REQUEST_STRING + queryString) else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            indicator.stopAnimating()
            
            let decoder = JSONDecoder()
            let volumeData = try decoder.decode(VolumeData.self, from: data)
            
            if let plants = volumeData.plants {
                newPlants.append(contentsOf: plants)
                print("Plants fetched: \(newPlants.count)") // Add this line to verify data
                tableView.reloadData()
            }
        } catch {
            print(error)
            indicator.stopAnimating()
        }
    }

    // Prepare for segue to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlantDetail",
           let destinationVC = segue.destination as? PlantDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.plant = newPlants[indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          performSegue(withIdentifier: "showPlantDetail", sender: self)
      }
}

import UIKit

class SearchPlantsTableViewController: UITableViewController, UISearchBarDelegate {
    
    let CELL_PLANT = "plantCell"
    let REQUEST_STRING = "https://perenual.com/api/species-list?key=sk-CPrZ664ea22fa60605611&q="
    var newPlants = [PlantData]()
    var indicator = UIActivityIndicatorView()
    var isLoadingMorePlants = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the navigation bar is visible
        navigationController?.navigationBar.isHidden = false
        
        // Set up the search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Plants"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Register the cell identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_PLANT)
        
        // Set up the activity indicator
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Fetch default plants when the view loads
        Task {
            await fetchDefaultPlants()
        }
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
        if let scientificNames = plant.scientificName {
            cell.detailTextLabel?.text = scientificNames.joined(separator: ", ")
        }
        return cell
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Clear the current plants
        newPlants.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        // Search for plants with the given name
        Task {
            await requestPlantsNamed(searchText, page: 1)
        }
    }

    func fetchDefaultPlants() async {
        let defaultPlantURLString = "https://perenual.com/api/species-list?key=sk-CPrZ664ea22fa60605611"
        guard let requestURL = URL(string: defaultPlantURLString) else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            indicator.stopAnimating()
            
            let decoder = JSONDecoder()
            let volumeData = try decoder.decode(VolumeData.self, from: data)
            
            if let plants = volumeData.plants {
                newPlants.append(contentsOf: plants)
                print("Default plants fetched: \(newPlants.count)") // Debug log
                tableView.reloadData()
            }
        } catch {
            print(error)
            indicator.stopAnimating()
        }
    }

    func requestPlantsNamed(_ plantName: String, page: Int = 1) async {
        guard let queryString = plantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let requestURL = URL(string: "\(REQUEST_STRING + queryString)&page=\(page)") else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            indicator.stopAnimating()
            
            let decoder = JSONDecoder()
            let volumeData = try decoder.decode(VolumeData.self, from: data)
            
            if let plants = volumeData.plants {
                newPlants.append(contentsOf: plants)
                print("Plants fetched: \(newPlants.count)") // Debug log
                tableView.reloadData()
            }
        } catch {
            print(error)
            indicator.stopAnimating()
        }
    }
    
    func loadMorePlants() async {
        isLoadingMorePlants = true
        let nextPage = (newPlants.count / 20) + 1 // Assuming each page returns 20 plants
        await requestPlantsNamed("", page: nextPage) // Modify this to include the current search text if needed
        isLoadingMorePlants = false
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 2 {
            if !isLoadingMorePlants {
                Task {
                    await loadMorePlants()
                }
            }
        }
    }

    // Prepare for segue to the detail view
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

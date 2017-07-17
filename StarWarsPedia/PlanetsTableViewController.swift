//
//  PlanetsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 23/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit


class PlanetsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    //This is property is passed through segue
    var store: DataStore!
    
    var planets = [Planet]()
    
    var filteredPlanets = [Planet]()
    let searchController = UISearchController(searchResultsController: nil)
    
    //--------------------
    //MARK: - View Methods
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        self.updateDataSource()
        
        //Search Bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        //searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundColor = UIColor.black
        searchController.searchBar.tintColor = UIColor.orange
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        tableView.tableHeaderView = searchController.searchBar
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add a background view to the table view
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bg_blurred"))
        self.tableView.backgroundView = imageView
    }
    
    
    //--------------------
    // MARK: - Table view data source
    //--------------------
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredPlanets.count
        }
        return planets.count

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "planetCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        let planet: Planet
        if searchController.isActive && searchController.searchBar.text != "" {
            planet = filteredPlanets[indexPath.row]
        } else {
            planet = planets[indexPath.row]
        }
        
        cell.textLabel?.text = planet.name
        return cell

        
    }
    
    
    
     //--------------------
     // MARK: - Navigation
     //--------------------
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Edit the back button title displayed in the next vc
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        switch segue.identifier {
        case "showPlanetDetails"?:
            if let selectedIndexPath = tableView.indexPathsForSelectedRows?.first {
                let planet: Planet
                if searchController.isActive && searchController.searchBar.text != "" {
                    planet = filteredPlanets[selectedIndexPath.row]
                } else {
                    planet = planets[selectedIndexPath.row]
                }
                let destinationVC = segue.destination as! PlanetDetailsTableViewController
                destinationVC.planet = planet
                destinationVC.store = store
            }

            
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
     }
 
    
    //--------------------
    //MARK: - Methods
    //--------------------
    
    private func updateDataSource() {
        store.fetchAllPlanetsFromDB { (planetsResult) in
            switch planetsResult {
            case let .success(planets):
                self.planets = planets
            case .failure(_):
                self.planets.removeAll()
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPlanets = planets.filter { planet in
            if let name = planet.name {
                let result = name.lowercased().contains(searchText.lowercased())
                return result
            } else {
                return false
            }
        }
        tableView.reloadData()
    }

    
}

extension PlanetsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}


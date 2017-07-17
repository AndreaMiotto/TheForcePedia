//
//  SpeciesTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 23/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit

class SpeciesTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    //This is property is passed through segue
    var store: DataStore!
    
    var species = [Specie]()
    
    var filteredSpecies = [Specie]()
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
        definesPresentationContext = true
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.tintColor = UIColor.orange
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
            return filteredSpecies.count
        }
        return species.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "specieCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        let specie: Specie
        if searchController.isActive && searchController.searchBar.text != "" {
            specie = filteredSpecies[indexPath.row]
        } else {
            specie = species[indexPath.row]
        }
        
        cell.textLabel?.text = specie.name
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
        case "showSpecieDetails"?:
            if let selectedIndexPath = tableView.indexPathsForSelectedRows?.first {
                let specie: Specie
                if searchController.isActive && searchController.searchBar.text != "" {
                    specie = filteredSpecies[selectedIndexPath.row]
                } else {
                    specie = species[selectedIndexPath.row]
                }
                let destinationVC = segue.destination as! SpecieDetailsTableViewController
                destinationVC.specie = specie
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
        store.fetchAllSpeciesFromDB { (speciesResult) in
            switch speciesResult {
            case let .success(species):
                self.species = species
            case .failure(_):
                self.species.removeAll()
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredSpecies = species.filter { specie in
            if let name = specie.name {
                let result = name.lowercased().contains(searchText.lowercased())
                return result
            } else {
                return false
            }
        }
        tableView.reloadData()
    }
    
}

extension SpeciesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}



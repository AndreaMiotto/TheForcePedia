//
//  PersonsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 18/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit

class PersonsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Outlets
    //--------------------
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    //This is property is passed through segue
    var store: DataStore!
    
    var persons = [Person]()
    var filteredPersons = [Person]()
    
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
            return filteredPersons.count
        }
        return persons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseIdentifier = "personCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        
        let person: Person
        if searchController.isActive && searchController.searchBar.text != "" {
            person = filteredPersons[indexPath.row]
        } else {
            person = persons[indexPath.row]
        }
        
        cell.textLabel?.text = person.name
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
        case "showPersonDetails"?:
            if let selectedIndexPath = tableView.indexPathsForSelectedRows?.first {
                let person: Person
                if searchController.isActive && searchController.searchBar.text != "" {
                    person = filteredPersons[selectedIndexPath.row]
                } else {
                    person = persons[selectedIndexPath.row]
                }
                let destinationVC = segue.destination as! PersonDetailsTableViewController
                destinationVC.person = person
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
        store.fetchAllPersonsFromDB { (personsResult) in
            switch personsResult {
            case let .success(persons):
                self.persons = persons
            case .failure(_):
                self.persons.removeAll()
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPersons = persons.filter { person in
            if let name = person.name {
                let result = name.lowercased().contains(searchText.lowercased())
                return result
            } else {
               return false
            }
        }
        tableView.reloadData()
    }

}

extension PersonsTableViewController: UISearchResultsUpdating {
        
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

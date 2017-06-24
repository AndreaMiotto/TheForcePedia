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
    //MARK: - Properties
    //--------------------
    
    //This is property is passed through segue
    var store: DataStore!
    
    var persons = [Person]()

    //--------------------
    //MARK: - View Methods
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        self.updateDataSource()
        
        /*
        store.fetchAllPersonsFromAPI() { (personResult) in
         self.updateDataSource()
        }
         */
 
 
    }

    
    //--------------------
    // MARK: - Table view data source
    //--------------------

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseIdentifier = "personCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = persons[indexPath.row].name
        return cell
     
    }
    

    
    //--------------------
    // MARK: - Navigation
    //--------------------

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPersonDetails"?:
            if let selectedIndexPath = tableView.indexPathsForSelectedRows?.first {
                let person = persons[selectedIndexPath.row]
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

}

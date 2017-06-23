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
    
    //--------------------
    //MARK: - View Methods
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        self.updateDataSource()
        
        /*
         store.fetchAllSpeciesFromAPI() { (specieResult) in
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
        return species.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "specieCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = species[indexPath.row].name
        return cell
        
    }
    
    
    /*
     //--------------------
     // MARK: - Navigation
     //--------------------
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
    
}



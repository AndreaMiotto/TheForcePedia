//
//  LandingViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 18/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit

class LandingViewController: UITableViewController {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    
    //This is property injection, check on
    //ApplicationDelegate.swift
    var store: DataStore!
    
    
    override func viewDidLoad() {
        store.fetchAllPersonsFromAPI() { (personResult) in
            print("characters downloaded")
        }
        
        store.fetchAllFilmsFromAPI { (filmResult) in
            print("films downloaded")
        }
        
        store.fetchAllPlanetsFromAPI { (planetResult) in
            print("planets downloaded")
        }
        
        store.fetchAllSpeciesFromAPI { (specieResult) in
            print("species downloaded")
        }
        
        store.fetchAllStarshipsFromAPI { (starshipResult) in
            print("starships downloaded")
        }
        
        store.fetchAllVehiclesFromAPI { (vehicleResult) in
            print("vehicles downloaded")
        }
    }
    
    
    //--------------------
    //MARK: - Methods
    //--------------------
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPersons"?:
            let destinationVC = segue.destination as! PersonsTableViewController
            destinationVC.store = store
            
        case "showFilms"?:
            let destinationVC = segue.destination as! FilmsTableViewController
            destinationVC.store = store
            
        case "showPlanets"?:
            let destinationVC = segue.destination as! PlanetsTableViewController
            destinationVC.store = store
            
        case "showSpecies"?:
            let destinationVC = segue.destination as! SpeciesTableViewController
            destinationVC.store = store
            
        case "showStarships"?:
            let destinationVC = segue.destination as! StarshipsTableViewController
            destinationVC.store = store
        case "showVehicles"?:
            let destinationVC = segue.destination as! VehiclesTableViewController
            destinationVC.store = store
        
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }

}

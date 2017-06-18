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
    
    
    //--------------------
    //MARK: - Methods
    //--------------------
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPersons"?:
            
            let destinationVC = segue.destination as! PersonsTableViewController
            destinationVC.store = store
        
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }

}

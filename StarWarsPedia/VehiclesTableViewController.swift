//
//  VehiclesTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 23/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit

class VehiclesTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    //This is property is passed through segue
    var store: DataStore!
    
    var vehicles = [Vehicle]()
    
    //--------------------
    //MARK: - View Methods
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        self.updateDataSource()
        
        /*
         store.fetchAllVehiclesFromAPI() { (vehicleResult) in
         self.updateDataSource()
         }
         */
        
        
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
        return vehicles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "vehicleCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = vehicles[indexPath.row].name
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
        store.fetchAllVehiclesFromDB { (vehiclesResult) in
            switch vehiclesResult {
            case let .success(vehicles):
                self.vehicles = vehicles
            case .failure(_):
                self.vehicles.removeAll()
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
}



//
//  VehicleDetailsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import CoreData

class VehicleDetailsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Outlets
    //--------------------
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    
    var vehicle: Vehicle!
    var store: DataStore!
    
    var persons: [Person] = []
    var films: [Film] = []
    
    //--------------------
    //MARK: - View's Methods
    //--------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = vehicle.name
        
        persons = vehicle.pilots?.allObjects as! [Person]
        films = vehicle.films?.allObjects as! [Film]
        
        updateConnections()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add a background view to the table view
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bg_blurred"))
        self.tableView.backgroundView = imageView
        
        self.tableView.estimatedRowHeight = 70 // for example. Set your average height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
    }
    
    //--------------------
    //MARK: - Table View Methods
    //--------------------
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 9
        case 1: return 1
        case 2: return persons.count
        case 3: return films.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.orange
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Details"
        case 1: return "Manufacturers"
        case 2: return "Pilots"
        case 3: return "Films"
        default: return "Section Header"
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = buildCellForDetails(withRowIndex: indexPath.row)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            if let manufacturer = vehicle.manufacturer {
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = manufacturer
            } else {
                cell.textLabel?.text = "unknow"
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = persons[indexPath.row].name
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = films[indexPath.row].title
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = "Unknown Cell"
        }
        return cell
    }
    
    
    //--------------------
    //MARK: - Methods
    //--------------------
    
    func buildCellForDetails(withRowIndex index: Int) -> UITableViewCell {
        
        let reuseIdentifier = "leftDetailCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .value2, reuseIdentifier: reuseIdentifier)
        switch index {
        case 0:
            cell.textLabel?.text = "Class:"
            if let s_class = vehicle.vehicle_class {
                cell.detailTextLabel?.text = s_class
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 1:
            cell.textLabel?.text = "Model:"
            if let model = vehicle.model {
                cell.detailTextLabel?.text = model
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 2:
            cell.textLabel?.text = "Atm Speed:"
            if vehicle.max_atmosphering_speed != 0 {
                cell.detailTextLabel?.text = "\(vehicle.max_atmosphering_speed)"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 3:
            cell.textLabel?.text = "Cost:"
            if vehicle.cost_in_credits != 0 {
                cell.detailTextLabel?.text = "\(vehicle.cost_in_credits) credits"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 4:
            cell.textLabel?.text = "Length:"
            if vehicle.length != 0 {
                cell.detailTextLabel?.text = "\(vehicle.length) mt."
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 5:
            cell.textLabel?.text = "Crew:"
            if vehicle.crew != 0 {
                cell.detailTextLabel?.text = "\(vehicle.crew)"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 6:
            cell.textLabel?.text = "Passengers:"
            if vehicle.passengers != 0 {
                cell.detailTextLabel?.text = "\(vehicle.passengers)"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 7:
            cell.textLabel?.text = "Stocks:"
            if let consumables = vehicle.consumables  {
                cell.detailTextLabel?.text = consumables
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 8:
            cell.textLabel?.text = "Cargo:"
            if vehicle.cargo_capacity != 0 {
                cell.detailTextLabel?.text = "\(vehicle.cargo_capacity) units"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        default: break;
        }
        return cell
        
    }
    
    ///make all the connections for the selected resource
    func updateConnections() {
        self.createPersonsConnection(fromVehicle: vehicle, toPersons: vehicle.pilot_urls)
        self.createFilmsConnection(fromVehicle: vehicle, toFilms: vehicle.film_urls)
        tableView.reloadData()
    }
    
    ///make the connections between the vehicle and the persons
    func createPersonsConnection(fromVehicle vehicle: Vehicle, toPersons persons: [String]?) {
        //check if the persons array url is empty
        guard let urls = persons else {
            return
        }
        //for each person url
        for url in urls {
            
            //Create the fetch request for the person
            let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
            let predicate = NSPredicate(format: "\(#keyPath(Person.url)) == %@", url)
            fetchRequest.predicate = predicate
            
            var fetchedPersons: [Person]?
            let context = store.persistentContainer.viewContext
            
            //make the request
            context.performAndWait {
                fetchedPersons = try? fetchRequest.execute()
            }
            //is there a person with the same url in the core data?
            if let existingPerson = fetchedPersons?.first {
                //Yes, make the connection
                vehicle.pilots?.adding(existingPerson)
                self.persons.append(existingPerson)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    
    ///make the connections between the vehicle and the films
    func createFilmsConnection(fromVehicle vehicle: Vehicle, toFilms films: [String]?) {
        //check if the films array url is empty
        guard let urls = films else {
            return
        }
        //for each films url
        for url in urls {
            
            //Create the fetch request for the film
            let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
            let predicate = NSPredicate(format: "\(#keyPath(Film.url)) == %@", url)
            fetchRequest.predicate = predicate
            
            var fetchedFilms: [Film]?
            let context = store.persistentContainer.viewContext
            
            //make the request
            context.performAndWait {
                fetchedFilms = try? fetchRequest.execute()
            }
            //is there a film with the same url in the core data?
            if let existingFilm = fetchedFilms?.first {
                //Yes, make the connection
                vehicle.films?.adding(existingFilm)
                self.films.append(existingFilm)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    //--------------------
    //MARK: - Actions
    //--------------------
    
    
    ///Display images for the resource through google images
    @IBAction func searchImages(_ sender: UIBarButtonItem) {
        guard  let name = vehicle.name else {
            return
        }
        //presenting the web view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        webViewController.stringToSearch = name
        
        self.present(webViewController, animated: true, completion: nil)
    }
    
    
   
    
}

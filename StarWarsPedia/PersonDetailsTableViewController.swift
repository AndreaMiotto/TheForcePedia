//
//  PersonDetailsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 24/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import CoreData

class PersonDetailsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Outlets
    //--------------------
    
    //--------------------
    //MARK: - Properties
    //--------------------
    

    var person: Person!
    var store: DataStore!
    
    //--------------------
    //MARK: - View's Methods
    //--------------------
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = person.name
    }

    //--------------------
    //MARK: - Table View Methods
    //--------------------
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 8
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Details"
        case 1: return "Films"
        case 2: return "Starships"
        case 3: return "Vehicles"
        default: return "section header"
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = buildCellForDetails(withRowIndex: indexPath.row)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        }

        return cell
    }
    
    
    //--------------------
    //MARK: - Methods
    //--------------------
    
    func buildCellForDetails(withRowIndex index: Int) -> UITableViewCell {
        
        let reuseIdentifier = "rightDetailCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
        switch index {
        case 0:
            cell.textLabel?.text = "Birth Year"
            if let birthYear = person.birth_year {
                cell.detailTextLabel?.text = birthYear
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 1:
            cell.textLabel?.text = "Gender"
            if let gender = person.gender {
                cell.detailTextLabel?.text = gender
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 2:
            cell.textLabel?.text = "Homeworld"
            //if the person has a connection with an homeworld
            if let homeworld = person.homeworld {
                cell.detailTextLabel?.text = homeworld.name
            //if not, try to make the connection
            } else if createPlanetConnection(fromPerson: person, toPlanet: person.homeworld_url) {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadRows(at: [indexPath] , with: .automatic)
            //if the connection fails, just print unknown
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 3:
            cell.textLabel?.text = "Height"
            if person.height != 0 {
                cell.detailTextLabel?.text = "\(person.height)"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 4:
            cell.textLabel?.text = "Mass"
            if person.mass != 0 {
                cell.detailTextLabel?.text = "\(person.mass)"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 5:
            cell.textLabel?.text = "Eye color"
            if let eyeColor = person.eye_color {
                cell.detailTextLabel?.text = eyeColor
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 6:
            cell.textLabel?.text = "Hair color"
            if let hairColor = person.hair_color {
                cell.detailTextLabel?.text = hairColor
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 7:
            cell.textLabel?.text = "Skin color"
            if let skinColor = person.skin_color {
                cell.detailTextLabel?.text = skinColor
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        default: break;
        }
        return cell
        
    }
    
    ///Return true if the connection has been made, false otherwise.
    func createPlanetConnection(fromPerson person: Person, toPlanet planet: String?) ->  Bool {
        //check if the planet url is empty
        guard let url = planet else {
            return false
        }
        
        //Create the fetch request for the planet
        let fetchRequest: NSFetchRequest<Planet> = Planet.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Planet.url)) == %@", url)
        fetchRequest.predicate = predicate
        
        var fetchedPlanets: [Planet]?
        
        let context = store.persistentContainer.viewContext
        
        //make the request
        context.performAndWait {
            fetchedPlanets = try? fetchRequest.execute()
        }
        //is there a planet with the same url in the core data?
        if let existingPlanet = fetchedPlanets?.first {
            //Yes, make the connection
            person.homeworld = existingPlanet
            
            do {
                try context.save()
            } catch let error {
                print("Impossible to make connection: \(error)")
                return false
            }
            
            //return treu
            return true
        }
        //No, so create it and we return it
        return false
            
    }
}

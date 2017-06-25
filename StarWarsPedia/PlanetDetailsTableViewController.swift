//
//  PlanetDetailsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import CoreData

class PlanetDetailsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Outlets
    //--------------------
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    
    var planet: Planet!
    var store: DataStore!
    
    var films: [Film] = []
    var persons: [Person] = []
    
    //--------------------
    //MARK: - View's Methods
    //--------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = planet.name
        films = planet.films?.allObjects as! [Film]
        persons = planet.residents?.allObjects as! [Person]
        
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 8
        case 1: return films.count
        case 2: return persons.count
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
        case 1: return "Films"
        case 2: return "Residents"
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
            cell.textLabel?.text = films[indexPath.row].title
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = persons[indexPath.row].name
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
            cell.textLabel?.text = "Climate:"
            if let climate = planet.climate {
                cell.detailTextLabel?.text = climate
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 1:
            cell.textLabel?.text = "Terrain:"
            if let terrain = planet.terrain {
                cell.detailTextLabel?.text = terrain
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 2:
            cell.textLabel?.text = "Water:"
            cell.detailTextLabel?.text = "\(planet.surface_water) %"
        case 3:
            cell.textLabel?.text = "Gravity:"
            cell.detailTextLabel?.text = "\(planet.gravity) Gs."
            
        case 4:
            cell.textLabel?.text = "Diameter:"
            if planet.diameter != 0 {
                cell.detailTextLabel?.text = "\(planet.diameter) km."
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 5:
            cell.textLabel?.text = "Population:"
            cell.detailTextLabel?.text = "\(planet.population)"

        case 6:
            cell.textLabel?.text = "Rotation:"
            if planet.rotation_period != 0 {
                cell.detailTextLabel?.text = "\(planet.rotation_period) hours"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 7:
            cell.textLabel?.text = "Orbit:"
            if planet.orbital_period != 0  {
                cell.detailTextLabel?.text = "\(planet.orbital_period) hours"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        default: break;
        }
        return cell
        
    }
    
    ///make all the connections for the selected resource
    func updateConnections() {
        self.createFilmsConnection(fromPlanet: planet, toFilms: planet.film_urls)
        self.createPersonsConnection(fromPlanet: planet, toPersons: planet.resident_urls)
        tableView.reloadData()
    }
    
    ///make the connections between the planet and the films
    func createFilmsConnection(fromPlanet planet: Planet, toFilms films: [String]?) {
        //check if the films array url is empty
        guard let urls = films else {
            return
        }
        //for each film url
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
                planet.films?.adding(existingFilm)
                self.films.append(existingFilm)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    
    ///make the connections between the planet and the characters
    func createPersonsConnection(fromPlanet planet: Planet, toPersons persons: [String]?) {
        //check if the persons array url is empty
        guard let urls = persons else {
            return
        }
        //for each persons url
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
            //is there a film with the same url in the core data?
            if let existingPerson = fetchedPersons?.first {
                //Yes, make the connection
                planet.residents?.adding(existingPerson)
                self.persons.append(existingPerson)
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
        guard  let name = planet.name else {
            return
        }
        //presenting the web view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        webViewController.stringToSearch = name
        self.present(webViewController, animated: true, completion: nil)
    }
    

}


//
//  SpecieDetailsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import CoreData

class SpecieDetailsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Outlets
    //--------------------
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    
    var specie: Specie!
    var store: DataStore!
    
    var films: [Film] = []
    var persons: [Person] = []
    
    //--------------------
    //MARK: - View's Methods
    //--------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = specie.name
        films = specie.films?.allObjects as! [Film]
        persons = specie.people?.allObjects as! [Person]
        
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
        case 0: return 9
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
        case 2: return "Characters"
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
            cell.textLabel?.text = "Classification:"
            if let classification = specie.classification {
                cell.detailTextLabel?.text = classification
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 1:
            cell.textLabel?.text = "Designation:"
            if let designation = specie.designation {
                cell.detailTextLabel?.text = designation
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 2:
            cell.textLabel?.text = "Homeworld:"
            //if the specie has a connection with an homeworld
            if let homeworld = specie.homeworld {
                cell.detailTextLabel?.text = homeworld.name
                //if not print unknown
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 3:
            cell.textLabel?.text = "Language:"
            if let language = specie.language {
                cell.detailTextLabel?.text = language
            } else {
                cell.detailTextLabel?.text = "unknown"
            }

        case 4:
            cell.textLabel?.text = "Height avg:"
            if specie.average_height != 0 {
                cell.detailTextLabel?.text = "\(specie.average_height) cm."
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 5:
            cell.textLabel?.text = "Lifespan avg:"
            if specie.average_lifespan != 0 {
                cell.detailTextLabel?.text = "\(specie.average_lifespan) years."
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 6:
            cell.textLabel?.text = "Eye color:"
            if let eyeColors = specie.eye_colors {
                cell.detailTextLabel?.text = eyeColors
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 7:
            cell.textLabel?.text = "Hair colors:"
            if let hairColors = specie.hair_colors {
                cell.detailTextLabel?.text = hairColors
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 8:
            cell.textLabel?.text = "Skin colors:"
            if let skinColors = specie.skin_colors {
                cell.detailTextLabel?.text = skinColors
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        default: break;
        }
        return cell
        
    }
    
    ///make all the connections for the selected resource
    func updateConnections() {
        self.createPlanetConnection(fromSpecie: specie, toPlanet: specie.homeworld_url)
        self.createFilmsConnection(fromSpecie: specie, toFilms: specie.film_urls)
        self.createPersonsConnection(fromSpecie: specie, toPersons: specie.character_urls)
        tableView.reloadData()
    }
    
    ///make the connections between the specie and the homeworld planet
    func createPlanetConnection(fromSpecie specie: Specie, toPlanet planet: String?) {
        //check if the planet url is empty
        guard let url = planet else {
            return
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
            specie.homeworld = existingPlanet
            
            do {
                try context.save()
            } catch let error {
                print("Impossible to make connection: \(error)")
                return
            }
        }
    }
    
    ///make the connections between the specie and the films
    func createFilmsConnection(fromSpecie specie: Specie, toFilms films: [String]?) {
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
                specie.films?.adding(existingFilm)
                self.films.append(existingFilm)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    
    ///make the connections between the specie and the characters
    func createPersonsConnection(fromSpecie specie: Specie, toPersons persons: [String]?) {
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
                specie.people?.adding(existingPerson)
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
        guard  let name = specie.name else {
            return
        }
        //presenting the web view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        webViewController.stringToSearch = name
        self.present(webViewController, animated: true, completion: nil)
    }
    
    
}

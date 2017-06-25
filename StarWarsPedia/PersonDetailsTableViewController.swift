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
    
    var films: [Film] = []
    var species: [Specie] = []
    var vehicles: [Vehicle] = []
    var starships: [Starship] = []
    
    //--------------------
    //MARK: - View's Methods
    //--------------------
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = person.name
        films = person.films?.allObjects as! [Film]
        species = person.species?.allObjects as! [Specie]
        vehicles = person.vehicles?.allObjects as! [Vehicle]
        starships = person.starships?.allObjects as! [Starship]
        
        updateConnections()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add a background view to the table view
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bg_blurred"))
        self.tableView.backgroundView = imageView
    }

    //--------------------
    //MARK: - Table View Methods
    //--------------------
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 8
        case 1: return species.count
        case 2: return films.count
        case 3: return starships.count
        case 4: return vehicles.count
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
        case 1: return "Species"
        case 2: return "Films"
        case 3: return "Starships"
        case 4: return "Vehicles"
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
            cell.textLabel?.text = species[indexPath.row].name
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = films[indexPath.row].title
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = starships[indexPath.row].name
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = vehicles[indexPath.row].name
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
            cell.textLabel?.text = "Birth Year:"
            if let birthYear = person.birth_year {
                cell.detailTextLabel?.text = birthYear
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 1:
            cell.textLabel?.text = "Gender:"
            if let gender = person.gender {
                cell.detailTextLabel?.text = gender
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 2:
            cell.textLabel?.text = "Homeworld:"
            //if the person has a connection with an homeworld
            if let homeworld = person.homeworld {
                cell.detailTextLabel?.text = homeworld.name
            //if not print unknown
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 3:
            cell.textLabel?.text = "Height:"
            if person.height != 0 {
                cell.detailTextLabel?.text = "\(person.height) cm."
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 4:
            cell.textLabel?.text = "Mass:"
            if person.mass != 0 {
                cell.detailTextLabel?.text = "\(person.mass) kg."
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 5:
            cell.textLabel?.text = "Eye color:"
            if let eyeColor = person.eye_color {
                cell.detailTextLabel?.text = eyeColor
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 6:
            cell.textLabel?.text = "Hair color:"
            if let hairColor = person.hair_color {
                cell.detailTextLabel?.text = hairColor
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 7:
            cell.textLabel?.text = "Skin color:"
            if let skinColor = person.skin_color {
                cell.detailTextLabel?.text = skinColor
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        default: break;
        }
        return cell
        
    }
    
    ///make all the connections for the selected resource
    func updateConnections() {
        self.createPlanetConnection(fromPerson: person, toPlanet: person.homeworld_url)
        self.createFilmsConnection(fromPerson: person, toFilms: person.film_urls)
        self.createSpeciesConnection(fromPerson: person, toSpecies: person.specie_urls)
        self.createStarshipsConnection(fromPerson: person, toStarships: person.starship_urls)
        self.createVehiclesConnection(fromPerson: person, toVehicles: person.vehicles_url)
        tableView.reloadData()
    }
    
    ///make the connections between the person and the homeworld planet
    func createPlanetConnection(fromPerson person: Person, toPlanet planet: String?) {
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
            person.homeworld = existingPlanet
            
            do {
                try context.save()
            } catch let error {
                print("Impossible to make connection: \(error)")
                return
            }
        }
    }
    
    ///make the connections between the person and the films
    func createFilmsConnection(fromPerson person: Person, toFilms films: [String]?) {
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
                person.films?.adding(existingFilm)
                self.films.append(existingFilm)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    
    ///make the connections between the person and the species
    func createSpeciesConnection(fromPerson person: Person, toSpecies species: [String]?) {
        //check if the films array url is empty
        guard let urls = species else {
            return
        }
        //for each species url
        for url in urls {
            
            //Create the fetch request for the specie
            let fetchRequest: NSFetchRequest<Specie> = Specie.fetchRequest()
            let predicate = NSPredicate(format: "\(#keyPath(Specie.url)) == %@", url)
            fetchRequest.predicate = predicate
            
            var fetchedSpecies: [Specie]?
            let context = store.persistentContainer.viewContext
            
            //make the request
            context.performAndWait {
                fetchedSpecies = try? fetchRequest.execute()
            }
            //is there a film with the same url in the core data?
            if let existingSpecie = fetchedSpecies?.first {
                //Yes, make the connection
                person.species?.adding(existingSpecie)
                self.species.append(existingSpecie)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    ///make the connections between the person and the vehicles
    func createVehiclesConnection(fromPerson person: Person, toVehicles vehicles: [String]?) {
        //check if the films array url is empty
        guard let urls = vehicles else {
            return
        }
        //for each vehicles url
        for url in urls {
            
            //Create the fetch request for the vehicle
            let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
            let predicate = NSPredicate(format: "\(#keyPath(Vehicle.url)) == %@", url)
            fetchRequest.predicate = predicate
            
            var fetchedVehicles: [Vehicle]?
            let context = store.persistentContainer.viewContext
            
            //make the request
            context.performAndWait {
                fetchedVehicles = try? fetchRequest.execute()
            }
            //is there a film with the same url in the core data?
            if let existingVehicle = fetchedVehicles?.first {
                //Yes, make the connection
                person.vehicles?.adding(existingVehicle)
                self.vehicles.append(existingVehicle)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    ///make the connections between the person and the starships
    func createStarshipsConnection(fromPerson person: Person, toStarships starships: [String]?) {
        //check if the films array url is empty
        guard let urls = starships else {
            return
        }
        //for each starships url
        for url in urls {
            
            //Create the fetch request for the starship
            let fetchRequest: NSFetchRequest<Starship> = Starship.fetchRequest()
            let predicate = NSPredicate(format: "\(#keyPath(Starship.url)) == %@", url)
            fetchRequest.predicate = predicate
            
            var fetchedStarships: [Starship]?
            let context = store.persistentContainer.viewContext
            
            //make the request
            context.performAndWait {
                fetchedStarships = try? fetchRequest.execute()
            }
            //is there a film with the same url in the core data?
            if let existingStarship = fetchedStarships?.first {
                //Yes, make the connection
                person.starships?.adding(existingStarship)
                self.starships.append(existingStarship)
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
        guard  let name = person.name else {
            return
        }
        //presenting the web view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        webViewController.stringToSearch = name
        self.present(webViewController, animated: true, completion: nil)
    }
    
    

}

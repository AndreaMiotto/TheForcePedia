//
//  FilmDetailsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//


import UIKit
import CoreData

class FilmDetailsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Outlets
    //--------------------
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    
    var film: Film!
    var store: DataStore!
    
    var species: [Specie] = []
    var vehicles: [Vehicle] = []
    var persons: [Person] = []
    var starships: [Starship] = []
    var planets: [Planet] = []
    
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    //--------------------
    //MARK: - View's Methods
    //--------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = film.title
        planets = film.planets?.allObjects as! [Planet]
        species = film.species?.allObjects as! [Specie]
        vehicles = film.vehicles?.allObjects as! [Vehicle]
        starships = film.starships?.allObjects as! [Starship]
        persons = film.characters?.allObjects as! [Person]
        
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
        return 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 1
        case 2: return species.count
        case 3: return planets.count
        case 4: return persons.count
        case 5: return starships.count
        case 6: return vehicles.count
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
        case 1: return "Opening Crawl"
        case 2: return "Species"
        case 3: return "Planets"
        case 4: return "Characters"
        case 5: return "Starships"
        case 6: return "Vehicles"
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
            if let crawl = film.opening_crawl {
                cell.textLabel?.numberOfLines = 0
                
                cell.textLabel?.text = crawl
                
            } else {
                cell.textLabel?.text = "unknow"
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = species[indexPath.row].name
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = planets[indexPath.row].name
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = persons[indexPath.row].name
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = starships[indexPath.row].name
        case 6:
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
            cell.textLabel?.text = "Episode:"
            if film.episode_id != 0 {
                cell.detailTextLabel?.text = "\(film.episode_id)"
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
            case 1:
            cell.textLabel?.text = "Director:"
            //if the person has a connection with an homeworld
            if let director = film.director {
                cell.detailTextLabel?.text = director
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 2:
            cell.textLabel?.text = "Producer:"
            if let producer = film.producer {
                cell.detailTextLabel?.text = producer
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        case 3:
            cell.textLabel?.text = "Release Date:"
            if let date = film.release_date {
                let stringDate = dateFormatter.string(from: date as Date)
                cell.detailTextLabel?.text = stringDate
            } else {
                cell.detailTextLabel?.text = "unknown"
            }
        default: break;
        }
        return cell
        
    }
    
    ///make all the connections for the selected resource
    func updateConnections() {
        self.createPlanetsConnection(fromPerson: film, toPlanets: film.planet_urls)
        self.createPersonsConnection(fromFilm: film, toPersons: film.character_urls)
        self.createSpeciesConnection(fromFilm: film, toSpecies: film.specie_urls)
        self.createStarshipsConnection(fromFilm: film, toStarships: film.starship_urls)
        self.createVehiclesConnection(fromFilm: film, toVehicles: film.vehicle_urls)
        tableView.reloadData()
    }
    
    ///make the connections between the person and the homeworld planet
    func createPlanetsConnection(fromPerson person: Film, toPlanets planets: [String]?) {
        //check if the planets array url is empty
        guard let urls = planets else {
            return
        }
        //for each species url
        for url in urls {
            
            //Create the fetch request for the specie
            let fetchRequest: NSFetchRequest<Planet> = Planet.fetchRequest()
            let predicate = NSPredicate(format: "\(#keyPath(Planet.url)) == %@", url)
            fetchRequest.predicate = predicate
            
            var fetchedPlanets: [Planet]?
            let context = store.persistentContainer.viewContext
            
            //make the request
            context.performAndWait {
                fetchedPlanets = try? fetchRequest.execute()
            }
            //is there a film with the same url in the core data?
            if let existingPlanet = fetchedPlanets?.first {
                //Yes, make the connection
                film.planets?.adding(existingPlanet)
                self.planets.append(existingPlanet)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }

        
    }
    
    ///make the connections between the person and the persons
    func createPersonsConnection(fromFilm film: Film, toPersons persons: [String]?) {
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
                film.characters?.adding(existingPerson)
                self.persons.append(existingPerson)
                do {
                    try context.save()
                } catch let error {
                    print("Impossible to make connection: \(error)")
                }
            }
        }
    }
    
    
    ///make the connections between the person and the species
    func createSpeciesConnection(fromFilm film: Film, toSpecies species: [String]?) {
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
                film.species?.adding(existingSpecie)
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
    func createVehiclesConnection(fromFilm film: Film, toVehicles vehicles: [String]?) {
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
                film.vehicles?.adding(existingVehicle)
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
    func createStarshipsConnection(fromFilm film: Film, toStarships starships: [String]?) {
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
                film.starships?.adding(existingStarship)
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
        guard  let name = film.title else {
            return
        }
        //presenting the web view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        webViewController.stringToSearch = name
        
        self.present(webViewController, animated: true, completion: nil)
    }
    
    
    
}

//
//  SWAPI.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 04/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import Foundation
import CoreData

///Defines the SWAPI errors */
enum SWAPIError: Error {
    case invalidJSONData
    case invalidURL
}

/// Defines the path for a certain resource
enum Method: String {
    case allPersons = "people/"
    case allFilms = "films/"
    case allPlanets = "planets/"
    case allSpecies = "species/"
    case allStarships = "starships/"
    case allVehicles = "vehicles/"
}



/// This **SWAPI** struct works as intermediate between the client and the SWAPI Web Service.
struct SWAPI {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    /// The base url for any request to the API
    private static let baseURLString = "https://swapi.co/api/"
    
    // The date formatter to build the date from the iso8601 format
    private static let dateFormatterISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    static var allFilmsURL: URL {
        return SWAPIURL(method: .allFilms)
    }
    
    static var allPersonsURL: URL {
        return SWAPIURL(method: .allPersons)
    }
    
    static var allPlanetsURL: URL {
        return SWAPIURL(method: .allPlanets)
    }
    
    static var allSpeciesURL: URL {
        return SWAPIURL(method: .allSpecies)
    }
    
    static var allStarshipsURL: URL {
        return SWAPIURL(method: .allStarships)
    }
    
    static var allVehiclesURL: URL {
        return SWAPIURL(method: .allVehicles)
    }
    
    
    //--------------------
    //MARK: -  General Methods
    //--------------------
    
    
    
    /// Method used to build the endpoint url
    private static func SWAPIURL(method: Method) -> URL {
        let baseURL = URL(string: baseURLString)!
        let finalURL = URL(string: method.rawValue, relativeTo: baseURL)!
        return finalURL
    }
    
    /// Method used to build the url for the next page
    static func nextPageURL(endpointURL: URL, withCurrentPage page: Int) -> URL {
        var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: true)!
        var queryItems = [URLQueryItem]()
        let queryItem = URLQueryItem(name: "page", value: "\(page+1)")
        queryItems.append(queryItem)
        components.queryItems = queryItems
        return components.url!
    }
    
    //--------------------
    //MARK: -  Persons Methods
    //--------------------
    
    ///Transform a bunch of data persons into an array of Persons. Returns an array of Persons with the next page URL
    static func persons(fromJSON data: Data, into context: NSManagedObjectContext) -> (PersonsResult, URL?) {
        do {
            //convert the jsonData into a jsonObject
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let personsArray = jsonDictionary["results"] as? [[String : Any]] else {
                    
                    //The JSON structure doesn't match our expectations
                    return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            var finalPersons = [Person]()
            for personJSON in personsArray {
                
                if let person = person(fromJSON: personJSON, into: context) {
                    finalPersons.append(person)
                }
            }
            
            if finalPersons.isEmpty && !personsArray.isEmpty {
                //We weren't able to parse any of the personss
                //Maybe the JSON format for persons has changed
                return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            //fetching the url for the next page of persons
            guard let urlString = jsonDictionary["next"] as? String, let url = URL(string: urlString) else {
                //if the next url points to nil
               return (.success(finalPersons), nil)
            }
            return (.success(finalPersons), url)
        } catch let error {
            return (.failure(error), nil)
        }
    }
    
    ///Transform the json person into a Person and return it.
    private static func person(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Person? {
        guard
            let name = json["name"] as? String,
            let birth_year = json["birth_year"] as? String,
            let eye_color = json["eye_color"] as? String,
            let gender = json["gender"] as? String,
            let hair_color = json["hair_color"] as? String,
            let skin_color = json["skin_color"] as? String,
            let heightString = json["height"] as? String,
            let massString = json["mass"] as? String,
            let editedString = json["edited"] as? String,
            let edited = dateFormatterISO8601.date(from: editedString),
            let homeworld_url = json["homeworld"] as? String,
            let url = json["url"] as? String else {
                
                //Don't have enough information to construct a Person
                print("Don't have enough information to construct a Person")
                return nil
        }
        
        //Need to know if we have already created a Person with the same name in the Core Data
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Person.name)) == %@", name)
        fetchRequest.predicate = predicate
        
        var fetchedPersons: [Person]?
        context.performAndWait {
            fetchedPersons = try? fetchRequest.execute()
        }
        //The person already exist in Core Data? Does it have the same edited date?
        if let existingPerson = fetchedPersons?.first, existingPerson.edited == (edited as NSDate) {
            //Yes, so return it
            return existingPerson
        }
        //No, so create it and we return it
        var person: Person!
        //use performAndWait (Synch vs perform Asynch) beacue
        //it has to return the person genereted into insert operation
        context.performAndWait {
            person = Person(context: context)
            person.name = name
            person.url = url
            person.birth_year = birth_year
            person.eye_color = eye_color
            person.gender = gender
            person.hair_color = hair_color
            person.skin_color = skin_color
            person.homeworld_url = homeworld_url
            
            if let height = Double(heightString) {
                person.height = height
            }
            if let mass = Double(massString) {
                person.mass = mass
            }
            
            
            person.edited = edited as NSDate
            
        }
        return person
    }
    
    //--------------------
    //MARK: -  Films Methods
    //--------------------
    
    ///Transform a bunch of data films into an array of Films. Returns an array of Films with the next page URL
    static func films(fromJSON data: Data, into context: NSManagedObjectContext) -> (FilmsResult, URL?) {
        do {
            //convert the jsonData into a jsonObject
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let filmsArray = jsonDictionary["results"] as? [[String : Any]] else {
                    
                    //The JSON structure doesn't match our expectations
                    return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            var finalFilms = [Film]()
            for filmJSON in filmsArray {
                if let film = film(fromJSON: filmJSON, into: context) {
                    finalFilms.append(film)
                }
            }
            
            if finalFilms.isEmpty && !filmsArray.isEmpty {
                //Weren't able to parse any of the films
                //Maybe the JSON format for films has changed
                return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            //fetching the url for the next page of films
            guard let urlString = jsonDictionary["next"] as? String, let url = URL(string: urlString) else {
                //if the next url points to nil
                return (.success(finalFilms), nil)
            }
            return (.success(finalFilms), url)
        } catch let error {
            return (.failure(error), nil)
        }
    }
    
    
    ///Transform the json film into a Film and return it.
    private static func film(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Film? {
        
        guard
            let title = json["title"] as? String,
            let url = json["url"] as? String,
            let producer = json["producer"] as? String,
            let opening_crawl = json["opening_crawl"] as? String,
            let director = json["director"] as? String,
            let episode_id = json["episode_id"] as? Int16,
            let editedString = json["edited"] as? String,
            let edited = dateFormatterISO8601.date(from: editedString),
            let release_dateString = json["release_date"] as? String else {
                
                //Don't have enough information to construct a film
                print("Don't have enough information to construct a film")
                return nil
        }
        
        //Need to know if we have already created a Film with the same title in the Core Data
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Film.title)) == %@", title)
        fetchRequest.predicate = predicate
        
        var fetchedFilms: [Film]?
        context.performAndWait {
            fetchedFilms = try? fetchRequest.execute()
        }
        //The film already exist in Core Data? Does it have the same edited date?
        if let existingFilm = fetchedFilms?.first, existingFilm.edited == (edited as NSDate)  {
            //yes, so return it
            return existingFilm
        }
        //No, so create it and we return it
        var film: Film!
        //use performAndWait (Synch vs perform Asynch) beacue
        //it has to return the film genereted into insert operation
        context.performAndWait {
            film = Film(context: context)
            film.title = title
            film.url = url
            film.director = director
            film.producer = producer
            film.opening_crawl = opening_crawl
            
            film.episode_id = episode_id
            
            
            film.edited = edited as NSDate
            
            
            if let release_date = dateFormatterISO8601.date(from: release_dateString) {
                film.release_date = release_date as NSDate
            }
            
        }
        return film
    }
    
    //--------------------
    //MARK: -  Planets Methods
    //--------------------
    
    ///Transform a bunch of data planets into an array of Planets. Returns an array of Planets with the next page URL
    static func planets(fromJSON data: Data, into context: NSManagedObjectContext) -> (PlanetsResult, URL?) {
        do {
            //convert the jsonData into a jsonObject
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let planetsArray = jsonDictionary["results"] as? [[String : Any]] else {
                    
                    //The JSON structure doesn't match our expectations
                    return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            var finalPlanets = [Planet]()
            for planetJSON in planetsArray {
                
                if let planet = planet(fromJSON: planetJSON, into: context) {
                    finalPlanets.append(planet)
                }
            }
            
            if finalPlanets.isEmpty && !planetsArray.isEmpty {
                //We weren't able to parse any of the planets
                //Maybe the JSON format for planets has changed
                return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            //fetching the url for the next page of planets
            guard let urlString = jsonDictionary["next"] as? String, let url = URL(string: urlString) else {
                //if the next url points to nil
                return (.success(finalPlanets), nil)
            }
            return (.success(finalPlanets), url)
        } catch let error {
            return (.failure(error), nil)
        }
    }
    
    ///Transform the json planet into a Planet and return it.
    private static func planet(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Planet? {
        guard
            let name = json["name"] as? String,
            let climate = json["climate"] as? String,
            let terrain = json["terrain"] as? String,
            let diameterString = json["diameter"] as? String,
            let gravityString = json["gravity"] as? String,
            let orbital_periodString = json["orbital_period"] as? String,
            let populationString = json["population"] as? String,
            let rotation_periodString = json["rotation_period"] as? String,
            let surface_waterString = json["surface_water"] as? String,
            let editedString = json["edited"] as? String,
            let edited = dateFormatterISO8601.date(from: editedString),
            let url = json["url"] as? String else {
                
                //Don't have enough information to construct a Planet
                print("Don't have enough information to construct a Planet")
                return nil
        }
        
        //Need to know if we have already created a Planet with the same name in the Core Data
        let fetchRequest: NSFetchRequest<Planet> = Planet.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Planet.name)) == %@", name)
        fetchRequest.predicate = predicate
        
        var fetchedPlanets: [Planet]?
        context.performAndWait {
            fetchedPlanets = try? fetchRequest.execute()
        }
        //The planet already exist in Core Data? Does it have the same edited date?
        if let existingPlanet = fetchedPlanets?.first, existingPlanet.edited == (edited as NSDate) {
            //Yes, so return it
            return existingPlanet
        }
        //No, so create it and we return it
        var planet: Planet!
        //use performAndWait (Synch vs perform Asynch) beacue
        //it has to return the planet genereted into insert operation
        context.performAndWait {
            planet = Planet(context: context)
            planet.name = name
            planet.terrain = terrain
            planet.climate = climate
            planet.url = url
            
            if let diameter = Int32(diameterString) {
                planet.diameter = diameter
            }
            if let gravity = Double(gravityString) {
                planet.gravity = gravity
            }
            if let orbital_period = Int16(orbital_periodString) {
                planet.orbital_period = orbital_period
            }
            if let population = Int64(populationString) {
                planet.population = population
            }
            if let rotation_period = Int16(rotation_periodString) {
                planet.rotation_period = rotation_period
            }
            if let surface_water = Double(surface_waterString) {
                planet.surface_water = surface_water
            }
            
            
            planet.edited = edited as NSDate
            
        }
        return planet
    }
    
    //--------------------
    //MARK: -  Species Methods
    //--------------------
    
    ///Transform a bunch of data species into an array of Species. Returns an array of Species with the next page URL
    static func species(fromJSON data: Data, into context: NSManagedObjectContext) -> (SpeciesResult, URL?) {
        do {
            //convert the jsonData into a jsonObject
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let speciesArray = jsonDictionary["results"] as? [[String : Any]] else {
                    
                    //The JSON structure doesn't match our expectations
                    return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            var finalSpecies = [Specie]()
            for specieJSON in speciesArray {
                
                if let specie = specie(fromJSON: specieJSON, into: context) {
                    finalSpecies.append(specie)
                }
            }
            
            if finalSpecies.isEmpty && !speciesArray.isEmpty {
                //We weren't able to parse any of the species
                //Maybe the JSON format for species has changed
                return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            //fetching the url for the next page of species
            guard let urlString = jsonDictionary["next"] as? String, let url = URL(string: urlString) else {
                //if the next url points to nil
                return (.success(finalSpecies), nil)
            }
            return (.success(finalSpecies), url)
        } catch let error {
            return (.failure(error), nil)
        }
    }
    
    ///Transform the json specie into a Specie and return it.
    private static func specie(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Specie? {
        guard
            let name = json["name"] as? String,
            let classficiation = json["classification"] as? String,
            let designation = json["designation"] as? String,
            let eye_colors = json["eye_colors"] as? String,
            let hair_colors = json["hair_colors"] as? String,
            let language = json["language"] as? String,
            let skin_colors = json["skin_colors"] as? String,
            let avarage_heightString = json["average_height"] as? String,
            let avarage_lifespanString = json["average_lifespan"] as? String,
            let editedString = json["edited"] as? String,
            let edited = dateFormatterISO8601.date(from: editedString),
            let url = json["url"] as? String else {
                
                //Don't have enough information to construct a Specie
                print("Don't have enough information to construct a Specie")
                return nil
        }
        
        //Need to know if we have already created a Specie with the same name in the Core Data
        let fetchRequest: NSFetchRequest<Specie> = Specie.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Specie.name)) == %@", name)
        fetchRequest.predicate = predicate
        
        var fetchedSpecies: [Specie]?
        context.performAndWait {
            fetchedSpecies = try? fetchRequest.execute()
        }
        //The specie already exist in Core Data? Does it have the same edited date?
        if let existingSpecie = fetchedSpecies?.first, existingSpecie.edited == (edited as NSDate) {
            //Yes, so return it
            return existingSpecie
        }
        //No, so create it and we return it
        var specie: Specie!
        //use performAndWait (Synch vs perform Asynch) beacue
        //it has to return the specie genereted into insert operation
        context.performAndWait {
            specie = Specie(context: context)
            specie.name = name
            specie.classification = classficiation
            specie.designation = designation
            specie.language = language
            specie.skin_colors = skin_colors
            specie.hair_colors = hair_colors
            specie.eye_colors = eye_colors
            specie.url = url
            
            if let avarage_height = Double(avarage_heightString) {
                specie.average_height = avarage_height
            }
            if let avarage_lifespan = Int16(avarage_lifespanString) {
                specie.average_lifespan = avarage_lifespan
            }
            
            
            specie.edited = edited as NSDate
            
        }
        return specie
    }
    
    //--------------------
    //MARK: -  Starhsips Methods
    //--------------------
    
    ///Transform a bunch of data starships into an array of Starships. Returns an array of Starships with the next page URL
    static func starships(fromJSON data: Data, into context: NSManagedObjectContext) -> (StarshipsResult, URL?) {
        do {
            //convert the jsonData into a jsonObject
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let starshipsArray = jsonDictionary["results"] as? [[String : Any]] else {
                    
                    //The JSON structure doesn't match our expectations
                    return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            var finalStarships = [Starship]()
            for starshipJSON in starshipsArray {
                
                if let starship = starship(fromJSON: starshipJSON, into: context) {
                    finalStarships.append(starship)
                } else {
                }
            }
            
            if finalStarships.isEmpty && !starshipsArray.isEmpty {
                //We weren't able to parse any of the starships
                //Maybe the JSON format for starships has changed
                return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            //fetching the url for the next page of starships
            guard let urlString = jsonDictionary["next"] as? String, let url = URL(string: urlString) else {
                //if the next url points to nil
                return (.success(finalStarships), nil)
            }
            return (.success(finalStarships), url)
        } catch let error {
            return (.failure(error), nil)
        }
    }
    
    ///Transform the json starship into a Starship and return it.
    private static func starship(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Starship? {
        guard
            let name = json["name"] as? String,
            let consumables = json["consumables"] as? String,
            let manufacturer = json["manufacturer"] as? String,
            let mglt = json["MGLT"] as? String,
            let model = json["model"] as? String,
            let starship_class = json["starship_class"] as? String,
            let cargo_capacityString = json["cargo_capacity"] as? String,
            let cost_in_creditsString = json["cost_in_credits"] as? String,
            let crewString = json["crew"] as? String,
            let lengthString = json["length"] as? String,
            let max_atmosphering_speedString = json["max_atmosphering_speed"] as? String,
            let passengersString = json["passengers"] as? String,
            let editedString = json["edited"] as? String,
            let edited = dateFormatterISO8601.date(from: editedString),
            let url = json["url"] as? String else {
                
                //Don't have enough information to construct a Starship
                print("Don't have enough information to construct a Starship")
                return nil
        }
        
        //Need to know if we have already created a Starship with the same name in the Core Data
        let fetchRequest: NSFetchRequest<Starship> = Starship.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Starship.name)) == %@", name)
        fetchRequest.predicate = predicate
        
        var fetchedStarships: [Starship]?
        context.performAndWait {
            fetchedStarships = try? fetchRequest.execute()
        }
        //The starship already exist in Core Data? Does it have the same edited date?
        if let existingStarship = fetchedStarships?.first, existingStarship.edited == (edited as NSDate) {
            //Yes, so return it
            return existingStarship
        }
        //No, so create it and we return it
        var starship: Starship!
        //use performAndWait (Synch vs perform Asynch) beacue
        //it has to return the starship genereted into insert operation
        context.performAndWait {
            starship = Starship(context: context)
            starship.name = name
            starship.url = url
            starship.consumables = consumables
            starship.manufacturer = manufacturer
            starship.mglt = mglt
            starship.model = model
            starship.starship_class = starship_class
            
            if let cargo_capacity = Int64(cargo_capacityString) {
                starship.cargo_capacity = cargo_capacity
            }
            if let cost_in_credits = Int32(cost_in_creditsString) {
               starship.cost_in_credits = cost_in_credits
            }
            if let crew = Int32(crewString) {
                starship.crew = crew
            }
            if let length = Int32(lengthString) {
                starship.length = length
            }
            if let  max_atmosphering_speed = Int32(max_atmosphering_speedString) {
                starship.max_atmosphering_speed = max_atmosphering_speed
            }
            if let passengers = Int32(passengersString) {
                starship.passengers = passengers
            }
            

            starship.edited = edited as NSDate
            
        }
        return starship
    }
    
    //--------------------
    //MARK: -  Vehicles Methods
    //--------------------
    
    ///Transform a bunch of data vehicles into an array of Vehicles. Returns an array of Vehicles with the next page URL
    static func vehicles(fromJSON data: Data, into context: NSManagedObjectContext) -> (VehiclesResult, URL?) {
        do {
            //convert the jsonData into a jsonObject
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let vehiclesArray = jsonDictionary["results"] as? [[String : Any]] else {
                    
                    //The JSON structure doesn't match our expectations
                    return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            var finalVehicles = [Vehicle]()
            for vehicleJSON in vehiclesArray {
                
                if let vehicle = vehicle(fromJSON: vehicleJSON, into: context) {
                    finalVehicles.append(vehicle)
                }
            }
            
            if finalVehicles.isEmpty && !vehiclesArray.isEmpty {
                //We weren't able to parse any of the vehicles
                //Maybe the JSON format for vehicles has changed
                return (.failure(SWAPIError.invalidJSONData), nil)
            }
            
            //fetching the url for the next page of vehicles
            guard let urlString = jsonDictionary["next"] as? String, let url = URL(string: urlString) else {
                //if the next url points to nil
                return (.success(finalVehicles), nil)
            }
            return (.success(finalVehicles), url)
        } catch let error {
            return (.failure(error), nil)
        }
    }
    
    ///Transform the json vehicle into a Vehicle and return it.
    private static func vehicle(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Vehicle? {
        guard
            let name = json["name"] as? String,
            let consumables = json["consumables"] as? String,
            let manufacturer = json["manufacturer"] as? String,
            let model = json["name"] as? String,
            let vehicle_class = json["vehicle_class"] as? String,
            let cargo_capacityString = json["cargo_capacity"] as? String,
            let cost_in_creditsString = json["cost_in_credits"] as? String,
            let crewString = json["crew"] as? String,
            let lengthString = json["length"] as? String,
            let max_atmosphering_speedString = json["max_atmosphering_speed"] as? String,
            let passengersString = json["passengers"] as? String,
            let url = json["url"] as? String,
            let editedString = json["edited"] as? String,
            let edited = dateFormatterISO8601.date(from: editedString) else {
                
                //Don't have enough information to construct a Vehicle
                print("Don't have enough information to construct a Vehicle")
                return nil
        }
        
        //Need to know if we have already created a Vehicle with the same name in the Core Data
        let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Vehicle.name)) == %@", name)
        fetchRequest.predicate = predicate
        
        var fetchedVehicles: [Vehicle]?
        context.performAndWait {
            fetchedVehicles = try? fetchRequest.execute()
        }
        //The vehicle already exist in Core Data? Does it have the same edited date?
        if let existingVehicle = fetchedVehicles?.first, existingVehicle.edited == (edited as NSDate) {
            //Yes, so return it
            return existingVehicle
        }
        //No, so create it and we return it
        var vehicle: Vehicle!
        //use performAndWait (Synch vs perform Asynch) beacue
        //it has to return the vehicle genereted into insert operation
        context.performAndWait {
            vehicle = Vehicle(context: context)
            vehicle.name = name
            vehicle.url = url
            vehicle.consumables = consumables
            vehicle.manufacturer = manufacturer
            vehicle.model = model
            vehicle.vehicle_class = vehicle_class
            
            if let cargo_capacity = Int64(cargo_capacityString) {
                vehicle.cargo_capacity = cargo_capacity
            }
            if let cost_in_credits = Int32(cost_in_creditsString) {
                vehicle.cost_in_credits = cost_in_credits
            }
            if let crew = Int32(crewString) {
                vehicle.crew = crew
            }
            if let length = Int32(lengthString) {
                vehicle.length = length
            }
            if let  max_atmosphering_speed = Int16(max_atmosphering_speedString) {
                vehicle.max_atmosphering_speed = max_atmosphering_speed
            }
            if let passengers = Int32(passengersString) {
                vehicle.passengers = passengers
            }
            
            vehicle.edited = edited as NSDate
            
 
        }
        return vehicle
    }

    //--------------------
    //MARK: - Helpers
    //--------------------

}


extension String {
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}

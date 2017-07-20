//
//  DataStore.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 06/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import CoreData

//--------------------
//MARK: - Result Types
//--------------------

enum PersonsResult {
    case success([Person])
    case failure(Error)
}

enum FilmsResult {
    case success([Film])
    case failure(Error)
}

enum PlanetsResult {
    case success([Planet])
    case failure(Error)
}

enum SpeciesResult {
    case success([Specie])
    case failure(Error)
}

enum StarshipsResult {
    case success([Starship])
    case failure(Error)
}

enum VehiclesResult {
    case success([Vehicle])
    case failure(Error)
}


//--------------------
//MARK: - Error Types
//--------------------

class DataStore {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    private  let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    let persistentContainer: NSPersistentContainer = {
        //Create a Persistent Conainer with a name, name is = as the CoreData Model
        let container = NSPersistentContainer(name: "StarWarsPedia")
        //Load the store, by default is a SQLite database
        //it's async 'cose it needs time
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        })
        return container
    }()
    
    
    //--------------------
    //MARK: - Person Methods
    //--------------------
    
    ///Fetch all persons from CoreData
    func fetchAllPersonsFromDB(completition: @escaping (PersonsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Person.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPersons = try viewContext.fetch(fetchRequest)
                completition(.success(allPersons))
            } catch {
                completition(.failure(error))
            }
        }
    }
    
    
    ///Fetch all the persons from the web Service (SWAPI)
    func fetchAllPersonsFromAPI(fromURL url:URL? = nil, completion: @escaping (PersonsResult) -> Void) {
        let request: URLRequest
        if let url = url {
            //Make a request with the url passed through
            request = URLRequest(url: url)
        } else {
            //Make a request with the SWAPI url
            let url = SWAPI.allPersonsURL
            request = URLRequest(url: url)
        }
        
        //create an istance of URLSessionTask
        //by giving the session a request and a completion closure
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let res = response as! HTTPURLResponse
            
            //Debug outputs
            print(res.statusCode)
            //----
            
            self.processPersonsRequest(data: data, error: error) { (result, NextPageURL) in
                OperationQueue.main.addOperation {
                    //if there is a next page
                    if let url = NextPageURL {
                        //make another request with the next page url
                        self.fetchAllPersonsFromAPI(fromURL: url, completion: completion)
                    }
                    completion(result)
                }
            }
        }
        //start the web service request
        task.resume()
    }
    
    
    
    ///Process the request to the API, returns a PersonResult object and an URL if there is a "next page" with the next page URL
    private func processPersonsRequest(data: Data?, error: Error?, completion: @escaping (PersonsResult, URL?) -> Void ) {
        guard let jsonData = data else {
            completion(.failure(error!), nil)
            return
        }
        
        //The following request is made in the background queue
        //beacuse it's an expensive task
        
        //create a background context
        persistentContainer.performBackgroundTask { (context) in
            
            //still convert the json data
            let result = SWAPI.persons(fromJSON: jsonData, into: context)
            
            let personResult = result.0
            let nextURL = result.1
            
            //try to save the context (still the background)
            do {
                try context.save()
            } catch {
                print("Error saving the Core Data: \(error).")
                completion(.failure(error), nil)
                return
            }
            
            //now we need to bring the context result into the main queue
            //to do that we extract the object identifier for each entity in the bg queue
            //than we create a reference with the entities in the main queue
            //and we call the completion closure on the referenced entities
            //of the main queue
            
            switch personResult {
            case let .success(persons):
                let personIDs = persons.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextPersons =  personIDs.map { return viewContext.object(with: $0) } as! [Person]
                completion(.success(viewContextPersons), nextURL)
            case .failure:
                completion(personResult, nextURL)
            }
        }
    }
    
    //--------------------
    //MARK: -  Films Methods
    //--------------------
    
    ///Fetch all films from CoreData
    func fetchAllFilmsFromDB(completition: @escaping (FilmsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
        let sortByTitle = NSSortDescriptor(key: #keyPath(Film.title), ascending: true)
        fetchRequest.sortDescriptors = [sortByTitle]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allFilms = try viewContext.fetch(fetchRequest)
                completition(.success(allFilms))
            } catch {
                completition(.failure(error))
            }
        }
    }
    
    
    
    ///Fetch all the films from the web Service (SWAPI)
    func fetchAllFilmsFromAPI(fromURL url:URL? = nil, completion: @escaping (FilmsResult) -> Void) {
        
        let request: URLRequest
        if let url = url {
            //Make a request with the url passed through
            request = URLRequest(url: url)
        } else {
            //Make a request with the SWAPI url
            let url = SWAPI.allFilmsURL
            request = URLRequest(url: url)
        }
        
        //create an istance of URLSessionTask
        //by giving the session a request and a completion closure
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            self.processFilmsRequest(data: data, error: error) { (result, NextPageURL) in
                OperationQueue.main.addOperation {
                    
                    //if there is a next page
                    if let url = NextPageURL {
                        //make another request with the next page url
                        self.fetchAllFilmsFromAPI(fromURL: url, completion: completion)
                    }
                    completion(result)
                }
            }
        }
        //start the web service request
        task.resume()
    }
    
    
    ///Process the request to the API, returns a PersonResult object and an URL if there is a "next page" with the next page URL
    private func processFilmsRequest(data: Data?, error: Error?, completion: @escaping (FilmsResult, URL?) -> Void ) {
        guard let jsonData = data else {
            completion(.failure(error!), nil)
            return
        }
        
        //The following request is made in the background queue
        //beacuse it's an expensive task
        
        //create a background context
        persistentContainer.performBackgroundTask { (context) in
            
            //still convert the json data
            let result = SWAPI.films(fromJSON: jsonData, into: context)
            let filmResult = result.0
            let nextURL = result.1
            
            //try to save the context (still the background)
            do {
                try context.save()
            } catch {
                print("Error saving the Core Data: \(error).")
                completion(.failure(error), nil)
                return
            }
            
            //now we need to bring the context result into the main queue
            //to do that we extract the object identifier for each entity in the bg queue
            //than we create a reference with the entities in the main queue
            //and we call the completion closure on the referenced entities
            //of the main queue
            
            switch filmResult {
            case let .success(films):
                let filmIDs = films.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextFilms =  filmIDs.map { return viewContext.object(with: $0) } as! [Film]
                completion(.success(viewContextFilms), nextURL)
            case .failure:
                completion(filmResult, nextURL)
            }
        }
    }
    
    
    //--------------------
    //MARK: - Planets Methods
    //--------------------
    
    ///Fetch all planets from CoreData
    func fetchAllPlanetsFromDB(completition: @escaping (PlanetsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Planet> = Planet.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Planet.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPlanets = try viewContext.fetch(fetchRequest)
                completition(.success(allPlanets))
            } catch {
                completition(.failure(error))
            }
        }
    }
    
    
    ///Fetch all the planets from the web Service (SWAPI)
    func fetchAllPlanetsFromAPI(fromURL url:URL? = nil, completion: @escaping (PlanetsResult) -> Void) {
        let request: URLRequest
        if let url = url {
            //Make a request with the url passed through
            request = URLRequest(url: url)
        } else {
            //Make a request with the SWAPI url
            let url = SWAPI.allPlanetsURL
            request = URLRequest(url: url)
        }
        
        //create an istance of URLSessionTask
        //by giving the session a request and a completion closure
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let res = response as! HTTPURLResponse
            
            //Debug outputs
            print(res.statusCode)
            //----
            
            self.processPlanetsRequest(data: data, error: error) { (result, NextPageURL) in
                OperationQueue.main.addOperation {
                    //if there is a next page
                    if let url = NextPageURL {
                        //make another request with the next page url
                        self.fetchAllPlanetsFromAPI(fromURL: url, completion: completion)
                    }
                    completion(result)
                }
            }
        }
        //start the web service request
        task.resume()
    }
    
    
    
    
    ///Process the request to the API, returns a PlanetsResult object and an URL if there is a "next page" with the next page URL
    private func processPlanetsRequest(data: Data?, error: Error?, completion: @escaping (PlanetsResult, URL?) -> Void ) {
        guard let jsonData = data else {
            completion(.failure(error!), nil)
            return
        }
        
        //The following request is made in the background queue
        //beacuse it's an expensive task
        
        //create a background context
        persistentContainer.performBackgroundTask { (context) in
            
            //still convert the json data
            let result = SWAPI.planets(fromJSON: jsonData, into: context)
            
            let planetResult = result.0
            let nextURL = result.1
            
            //try to save the context (still the background)
            do {
                try context.save()
            } catch {
                print("Error saving the Core Data: \(error).")
                completion(.failure(error), nil)
                return
            }
            
            //now we need to bring the context result into the main queue
            //to do that we extract the object identifier for each entity in the bg queue
            //than we create a reference with the entities in the main queue
            //and we call the completion closure on the referenced entities
            //of the main queue
            
            switch planetResult {
            case let .success(planets):
                let planetIDs = planets.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextPlanets =  planetIDs.map { return viewContext.object(with: $0) } as! [Planet]
                completion(.success(viewContextPlanets), nextURL)
            case .failure:
                completion(planetResult, nextURL)
            }
        }
    }
    
    
    
    //--------------------
    //MARK: -  Species Methods
    //--------------------
    
    ///Fetch all species from CoreData
    func fetchAllSpeciesFromDB(completition: @escaping (SpeciesResult) -> Void) {
        let fetchRequest: NSFetchRequest<Specie> = Specie.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Specie.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allSpecies = try viewContext.fetch(fetchRequest)
                completition(.success(allSpecies))
            } catch {
                completition(.failure(error))
            }
        }
    }
    
    
    ///Fetch all the species from the web Service (SWAPI)
    func fetchAllSpeciesFromAPI(fromURL url:URL? = nil, completion: @escaping (SpeciesResult) -> Void) {
        let request: URLRequest
        if let url = url {
            //Make a request with the url passed through
            request = URLRequest(url: url)
        } else {
            //Make a request with the SWAPI url
            let url = SWAPI.allSpeciesURL
            request = URLRequest(url: url)
        }
        
        //create an istance of URLSessionTask
        //by giving the session a request and a completion closure
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let res = response as! HTTPURLResponse
            
            //Debug outputs
            print(res.statusCode)
            //----
            
            self.processSpeciesRequest(data: data, error: error) { (result, NextPageURL) in
                OperationQueue.main.addOperation {
                    //if there is a next page
                    if let url = NextPageURL {
                        //make another request with the next page url
                        self.fetchAllSpeciesFromAPI(fromURL: url, completion: completion)
                    }
                    completion(result)
                }
            }
        }
        //start the web service request
        task.resume()
    }
    
    
    
    
    ///Process the request to the API, returns a SpeciesResult object and an URL if there is a "next page" with the next page URL
    private func processSpeciesRequest(data: Data?, error: Error?, completion: @escaping (SpeciesResult, URL?) -> Void ) {
        guard let jsonData = data else {
            completion(.failure(error!), nil)
            return
        }
        
        //The following request is made in the background queue
        //beacuse it's an expensive task
        
        //create a background context
        persistentContainer.performBackgroundTask { (context) in
            
            //still convert the json data
            let result = SWAPI.species(fromJSON: jsonData, into: context)
            
            let specieResult = result.0
            let nextURL = result.1
            
            //try to save the context (still the background)
            do {
                try context.save()
            } catch {
                print("Error saving the Core Data: \(error).")
                completion(.failure(error), nil)
                return
            }
            
            //now we need to bring the context result into the main queue
            //to do that we extract the object identifier for each entity in the bg queue
            //than we create a reference with the entities in the main queue
            //and we call the completion closure on the referenced entities
            //of the main queue
            
            switch specieResult {
            case let .success(species):
                let specieIDs = species.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextSpecies =  specieIDs.map { return viewContext.object(with: $0) } as! [Specie]
                completion(.success(viewContextSpecies), nextURL)
            case .failure:
                completion(specieResult, nextURL)
            }
        }
    }
    
    
    //--------------------
    //MARK: -  Starhsips Methods
    //--------------------
    
    ///Fetch all starships from CoreData
    func fetchAllStarshipsFromDB(completition: @escaping (StarshipsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Starship> = Starship.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Starship.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allStarships = try viewContext.fetch(fetchRequest)
                completition(.success(allStarships))
            } catch {
                completition(.failure(error))
            }
        }
    }
    
    
    ///Fetch all the starships from the web Service (SWAPI)
    func fetchAllStarshipsFromAPI(fromURL url:URL? = nil, completion: @escaping (StarshipsResult) -> Void) {
        let request: URLRequest
        if let url = url {
            //Make a request with the url passed through
            request = URLRequest(url: url)
        } else {
            //Make a request with the SWAPI url
            let url = SWAPI.allStarshipsURL
            request = URLRequest(url: url)
        }
        
        //create an istance of URLSessionTask
        //by giving the session a request and a completion closure
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let res = response as! HTTPURLResponse
            
            //Debug outputs
            print(res.statusCode)
            //----
            
            self.processStarshipsRequest(data: data, error: error) { (result, NextPageURL) in
                OperationQueue.main.addOperation {
                    //if there is a next page
                    if let url = NextPageURL {
                        //make another request with the next page url
                        self.fetchAllStarshipsFromAPI(fromURL: url, completion: completion)
                    }
                    completion(result)
                }
            }
        }
        //start the web service request
        task.resume()
    }
    
    
    
    
    ///Process the request to the API, returns a StarshipsResult object and an URL if there is a "next page" with the next page URL
    private func processStarshipsRequest(data: Data?, error: Error?, completion: @escaping (StarshipsResult, URL?) -> Void ) {
        guard let jsonData = data else {
            completion(.failure(error!), nil)
            return
        }
        
        //The following request is made in the background queue
        //beacuse it's an expensive task
        
        //create a background context
        persistentContainer.performBackgroundTask { (context) in
            
            //still convert the json data
            let result = SWAPI.starships(fromJSON: jsonData, into: context)
            
            let starshipResult = result.0
            let nextURL = result.1
            
            //try to save the context (still the background)
            do {
                try context.save()
            } catch {
                print("Error saving the Core Data: \(error).")
                completion(.failure(error), nil)
                return
            }
            
            //now we need to bring the context result into the main queue
            //to do that we extract the object identifier for each entity in the bg queue
            //than we create a reference with the entities in the main queue
            //and we call the completion closure on the referenced entities
            //of the main queue
            
            switch starshipResult {
            case let .success(starships):
                let starshipIDs = starships.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextStarships =  starshipIDs.map { return viewContext.object(with: $0) } as! [Starship]
                completion(.success(viewContextStarships), nextURL)
            case .failure:
                completion(starshipResult, nextURL)
            }
        }
    }
    
    //--------------------
    //MARK: -  Vehicles Methods
    //--------------------
    
    ///Fetch all vehicles from CoreData
    func fetchAllVehiclesFromDB(completition: @escaping (VehiclesResult) -> Void) {
        let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Vehicle.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allVehicles = try viewContext.fetch(fetchRequest)
                completition(.success(allVehicles))
            } catch {
                completition(.failure(error))
            }
        }
    }
    
    
    ///Fetch all the vehicles from the web Service (SWAPI)
    func fetchAllVehiclesFromAPI(fromURL url:URL? = nil, completion: @escaping (VehiclesResult) -> Void) {
        let request: URLRequest
        if let url = url {
            //Make a request with the url passed through
            request = URLRequest(url: url)
        } else {
            //Make a request with the SWAPI url
            let url = SWAPI.allVehiclesURL
            request = URLRequest(url: url)
        }
        
        //create an istance of URLSessionTask
        //by giving the session a request and a completion closure
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let res = response as! HTTPURLResponse
            
            //Debug outputs
            print(res.statusCode)
            //----
            
            self.processVehiclesRequest(data: data, error: error) { (result, NextPageURL) in
                OperationQueue.main.addOperation {
                    //if there is a next page
                    if let url = NextPageURL {
                        //make another request with the next page url
                        self.fetchAllVehiclesFromAPI(fromURL: url, completion: completion)
                    }
                    completion(result)
                }
            }
        }
        //start the web service request
        task.resume()
    }
    
    
    
    
    ///Process the request to the API, returns a VehiclesResult object and an URL if there is a "next page" with the next page URL
    private func processVehiclesRequest(data: Data?, error: Error?, completion: @escaping (VehiclesResult, URL?) -> Void ) {
        guard let jsonData = data else {
            completion(.failure(error!), nil)
            return
        }
        
        //The following request is made in the background queue
        //beacuse it's an expensive task
        
        //create a background context
        persistentContainer.performBackgroundTask { (context) in
            
            //still convert the json data
            let result = SWAPI.vehicles(fromJSON: jsonData, into: context)
            
            let vehicleResult = result.0
            let nextURL = result.1
            
            //try to save the context (still the background)
            do {
                try context.save()
            } catch {
                print("Error saving the Core Data: \(error).")
                completion(.failure(error), nil)
                return
            }
            
            //now we need to bring the context result into the main queue
            //to do that we extract the object identifier for each entity in the bg queue
            //than we create a reference with the entities in the main queue
            //and we call the completion closure on the referenced entities
            //of the main queue
            
            switch vehicleResult {
            case let .success(vehicles):
                let vehicleIDs = vehicles.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextVehicles =  vehicleIDs.map { return viewContext.object(with: $0) } as! [Vehicle]
                completion(.success(viewContextVehicles), nextURL)
            case .failure:
                completion(vehicleResult, nextURL)
            }
        }
    }
    
    //--------------------
    //MARK: - Helpers
    //--------------------
    
}












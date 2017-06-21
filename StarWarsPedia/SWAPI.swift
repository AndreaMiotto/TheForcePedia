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
    case allStarships = "starhips/"
    case allVehicles = "vehicles/"
    
}



/// This **SWAPI** struct works as intermediate between the client and the SWAPI Web Service.
struct SWAPI {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    /// The base url for any request to the API
    private static let baseURLString = "https://swapi.co/api/"
    
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
        //The person already exist in Core Data?
        if let existingPerson = fetchedPersons?.first {
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
            let director = json["director"] as? String else {
                
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
        //The film already exist in Core Data?
        if let existingFilm = fetchedFilms?.first {
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
            
        }
        return film
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

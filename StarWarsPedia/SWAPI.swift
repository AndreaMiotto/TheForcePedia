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
    
    static func persons(fromJSON data: Data, into context: NSManagedObjectContext) -> PersonsResult {
        do {
            //convert the jsonData into a jsonObject
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let personsArray = jsonDictionary["results"] as? [[String : Any]] else {
                    
                    //The JSON structure doesn't match our expectations
                    return .failure(SWAPIError.invalidJSONData)
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
                return .failure(SWAPIError.invalidJSONData)
            }
            
            return .success(finalPersons)
        } catch let error {
            return .failure(error)
        }
    }
    
    private static func person(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Person? {
        
        guard
            let name = json["name"] as? String,
            let url = json["url"] as? String/*,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString)*/ else {
                
                //Don't have enough information to construct a Photo
                return nil
        }
        
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Person.name)) == %@", name)
        fetchRequest.predicate = predicate
        
        var fetchedPersons: [Person]?
        context.performAndWait {
            fetchedPersons = try? fetchRequest.execute()
        }
        if let existingPerson = fetchedPersons?.first {
            return existingPerson
        }
        
        var person: Person!
        //use performAndWait (Synch vs perform Asynch) beacue
        //it has to return the photo genereted into insert operation
        context.performAndWait {
            person = Person(context: context)
            person.name = name
            person.url = url
        }
        return person
    }

    
    
    
    
    
    //--------------------
    //MARK: - Helpers
    //--------------------

}

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
    case allFilms = "films/"
    case allPeople = "people/"
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
    private static let baseURLString = "http://swapi.co/api/"
    
    static var allFilmsURL: URL {
        return SWAPIURL(method: .allFilms)
    }
    
    static var allPeopleURL: URL {
        return SWAPIURL(method: .allPeople)
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
    //MARK: -  People Methods
    //--------------------
    

    
    
    
    
    
    //--------------------
    //MARK: - Helpers
    //--------------------

}

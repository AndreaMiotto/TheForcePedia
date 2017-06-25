//
//  Film+CoreDataProperties.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import Foundation
import CoreData


extension Film {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Film> {
        return NSFetchRequest<Film>(entityName: "Film")
    }

    @NSManaged public var director: String?
    @NSManaged public var edited: NSDate?
    @NSManaged public var episode_id: Int16
    @NSManaged public var opening_crawl: String?
    @NSManaged public var producer: String?
    @NSManaged public var release_date: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var character_urls: [String]?
    @NSManaged public var planet_urls: [String]?
    @NSManaged public var vehicle_urls: [String]?
    @NSManaged public var starship_urls: [String]?
    @NSManaged public var specie_urls: [String]?
    @NSManaged public var characters: NSSet?
    @NSManaged public var planets: NSSet?
    @NSManaged public var species: NSSet?
    @NSManaged public var starships: NSSet?
    @NSManaged public var vehicles: NSSet?

}

// MARK: Generated accessors for characters
extension Film {

    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Person)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Person)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: NSSet)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: NSSet)

}

// MARK: Generated accessors for planets
extension Film {

    @objc(addPlanetsObject:)
    @NSManaged public func addToPlanets(_ value: Planet)

    @objc(removePlanetsObject:)
    @NSManaged public func removeFromPlanets(_ value: Planet)

    @objc(addPlanets:)
    @NSManaged public func addToPlanets(_ values: NSSet)

    @objc(removePlanets:)
    @NSManaged public func removeFromPlanets(_ values: NSSet)

}

// MARK: Generated accessors for species
extension Film {

    @objc(addSpeciesObject:)
    @NSManaged public func addToSpecies(_ value: Specie)

    @objc(removeSpeciesObject:)
    @NSManaged public func removeFromSpecies(_ value: Specie)

    @objc(addSpecies:)
    @NSManaged public func addToSpecies(_ values: NSSet)

    @objc(removeSpecies:)
    @NSManaged public func removeFromSpecies(_ values: NSSet)

}

// MARK: Generated accessors for starships
extension Film {

    @objc(addStarshipsObject:)
    @NSManaged public func addToStarships(_ value: Starship)

    @objc(removeStarshipsObject:)
    @NSManaged public func removeFromStarships(_ value: Starship)

    @objc(addStarships:)
    @NSManaged public func addToStarships(_ values: NSSet)

    @objc(removeStarships:)
    @NSManaged public func removeFromStarships(_ values: NSSet)

}

// MARK: Generated accessors for vehicles
extension Film {

    @objc(addVehiclesObject:)
    @NSManaged public func addToVehicles(_ value: Vehicle)

    @objc(removeVehiclesObject:)
    @NSManaged public func removeFromVehicles(_ value: Vehicle)

    @objc(addVehicles:)
    @NSManaged public func addToVehicles(_ values: NSSet)

    @objc(removeVehicles:)
    @NSManaged public func removeFromVehicles(_ values: NSSet)

}

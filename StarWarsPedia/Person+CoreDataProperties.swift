//
//  Person+CoreDataProperties.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 24/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var birth_year: String?
    @NSManaged public var edited: NSDate?
    @NSManaged public var eye_color: String?
    @NSManaged public var gender: String?
    @NSManaged public var hair_color: String?
    @NSManaged public var height: Double
    @NSManaged public var mass: Double
    @NSManaged public var name: String?
    @NSManaged public var skin_color: String?
    @NSManaged public var url: String?
    @NSManaged public var homeworld_url: String?
    @NSManaged public var film_urls: [String]?
    @NSManaged public var specie_urls: [String]?
    @NSManaged public var starship_urls: [String]?
    @NSManaged public var vehicles_url: [String]?
    @NSManaged public var films: NSSet?
    @NSManaged public var homeworld: Planet?
    @NSManaged public var species: NSSet?
    @NSManaged public var starships: NSSet?
    @NSManaged public var vehicles: NSSet?

}

// MARK: Generated accessors for films
extension Person {

    @objc(addFilmsObject:)
    @NSManaged public func addToFilms(_ value: Film)

    @objc(removeFilmsObject:)
    @NSManaged public func removeFromFilms(_ value: Film)

    @objc(addFilms:)
    @NSManaged public func addToFilms(_ values: NSSet)

    @objc(removeFilms:)
    @NSManaged public func removeFromFilms(_ values: NSSet)

}

// MARK: Generated accessors for species
extension Person {

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
extension Person {

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
extension Person {

    @objc(addVehiclesObject:)
    @NSManaged public func addToVehicles(_ value: Vehicle)

    @objc(removeVehiclesObject:)
    @NSManaged public func removeFromVehicles(_ value: Vehicle)

    @objc(addVehicles:)
    @NSManaged public func addToVehicles(_ values: NSSet)

    @objc(removeVehicles:)
    @NSManaged public func removeFromVehicles(_ values: NSSet)

}

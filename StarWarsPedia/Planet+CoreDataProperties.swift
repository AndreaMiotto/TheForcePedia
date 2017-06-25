//
//  Planet+CoreDataProperties.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import Foundation
import CoreData


extension Planet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Planet> {
        return NSFetchRequest<Planet>(entityName: "Planet")
    }

    @NSManaged public var climate: String?
    @NSManaged public var diameter: Int32
    @NSManaged public var edited: NSDate?
    @NSManaged public var gravity: Double
    @NSManaged public var name: String?
    @NSManaged public var orbital_period: Int16
    @NSManaged public var population: Int64
    @NSManaged public var rotation_period: Int16
    @NSManaged public var surface_water: Double
    @NSManaged public var terrain: String?
    @NSManaged public var url: String?
    @NSManaged public var film_urls: [String]?
    @NSManaged public var resident_urls: [String]?
    @NSManaged public var films: NSSet?
    @NSManaged public var residents: NSSet?
    @NSManaged public var species: Specie?

}

// MARK: Generated accessors for films
extension Planet {

    @objc(addFilmsObject:)
    @NSManaged public func addToFilms(_ value: Film)

    @objc(removeFilmsObject:)
    @NSManaged public func removeFromFilms(_ value: Film)

    @objc(addFilms:)
    @NSManaged public func addToFilms(_ values: NSSet)

    @objc(removeFilms:)
    @NSManaged public func removeFromFilms(_ values: NSSet)

}

// MARK: Generated accessors for residents
extension Planet {

    @objc(addResidentsObject:)
    @NSManaged public func addToResidents(_ value: Person)

    @objc(removeResidentsObject:)
    @NSManaged public func removeFromResidents(_ value: Person)

    @objc(addResidents:)
    @NSManaged public func addToResidents(_ values: NSSet)

    @objc(removeResidents:)
    @NSManaged public func removeFromResidents(_ values: NSSet)

}

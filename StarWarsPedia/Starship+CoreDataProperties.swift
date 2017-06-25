//
//  Starship+CoreDataProperties.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import Foundation
import CoreData


extension Starship {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Starship> {
        return NSFetchRequest<Starship>(entityName: "Starship")
    }

    @NSManaged public var cargo_capacity: Int64
    @NSManaged public var consumables: String?
    @NSManaged public var cost_in_credits: Int32
    @NSManaged public var crew: Int32
    @NSManaged public var edited: NSDate?
    @NSManaged public var hyperdrive_rating: Double
    @NSManaged public var length: Int32
    @NSManaged public var manufacturer: String?
    @NSManaged public var max_atmosphering_speed: Int32
    @NSManaged public var mglt: String?
    @NSManaged public var model: String?
    @NSManaged public var name: String?
    @NSManaged public var passengers: Int32
    @NSManaged public var starship_class: String?
    @NSManaged public var url: String?
    @NSManaged public var film_urls: [String]?
    @NSManaged public var pilot_urls: [String]?
    @NSManaged public var films: NSSet?
    @NSManaged public var pilots: NSSet?

}

// MARK: Generated accessors for films
extension Starship {

    @objc(addFilmsObject:)
    @NSManaged public func addToFilms(_ value: Film)

    @objc(removeFilmsObject:)
    @NSManaged public func removeFromFilms(_ value: Film)

    @objc(addFilms:)
    @NSManaged public func addToFilms(_ values: NSSet)

    @objc(removeFilms:)
    @NSManaged public func removeFromFilms(_ values: NSSet)

}

// MARK: Generated accessors for pilots
extension Starship {

    @objc(addPilotsObject:)
    @NSManaged public func addToPilots(_ value: Person)

    @objc(removePilotsObject:)
    @NSManaged public func removeFromPilots(_ value: Person)

    @objc(addPilots:)
    @NSManaged public func addToPilots(_ values: NSSet)

    @objc(removePilots:)
    @NSManaged public func removeFromPilots(_ values: NSSet)

}

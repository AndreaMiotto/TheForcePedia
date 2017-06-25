//
//  Vehicle+CoreDataProperties.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var cargo_capacity: Int64
    @NSManaged public var consumables: String?
    @NSManaged public var cost_in_credits: Int32
    @NSManaged public var crew: Int32
    @NSManaged public var edited: NSDate?
    @NSManaged public var length: Int32
    @NSManaged public var manufacturer: String?
    @NSManaged public var max_atmosphering_speed: Int16
    @NSManaged public var model: String?
    @NSManaged public var name: String?
    @NSManaged public var passengers: Int32
    @NSManaged public var url: String?
    @NSManaged public var vehicle_class: String?
    @NSManaged public var film_urls: [String]?
    @NSManaged public var pilot_urls: [String]?
    @NSManaged public var films: NSSet?
    @NSManaged public var pilots: NSSet?

}

// MARK: Generated accessors for films
extension Vehicle {

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
extension Vehicle {

    @objc(addPilotsObject:)
    @NSManaged public func addToPilots(_ value: Person)

    @objc(removePilotsObject:)
    @NSManaged public func removeFromPilots(_ value: Person)

    @objc(addPilots:)
    @NSManaged public func addToPilots(_ values: NSSet)

    @objc(removePilots:)
    @NSManaged public func removeFromPilots(_ values: NSSet)

}

//
//  Specie+CoreDataProperties.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 25/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import Foundation
import CoreData


extension Specie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Specie> {
        return NSFetchRequest<Specie>(entityName: "Specie")
    }

    @NSManaged public var average_height: Double
    @NSManaged public var average_lifespan: Int16
    @NSManaged public var classification: String?
    @NSManaged public var designation: String?
    @NSManaged public var edited: NSDate?
    @NSManaged public var eye_colors: String?
    @NSManaged public var hair_colors: String?
    @NSManaged public var language: String?
    @NSManaged public var name: String?
    @NSManaged public var skin_colors: String?
    @NSManaged public var url: String?
    @NSManaged public var homeworld_url: [String]?
    @NSManaged public var character_urls: [String]?
    @NSManaged public var film_urls: [String]?
    @NSManaged public var films: NSSet?
    @NSManaged public var homeworld: Planet?
    @NSManaged public var people: NSSet?

}

// MARK: Generated accessors for films
extension Specie {

    @objc(addFilmsObject:)
    @NSManaged public func addToFilms(_ value: Film)

    @objc(removeFilmsObject:)
    @NSManaged public func removeFromFilms(_ value: Film)

    @objc(addFilms:)
    @NSManaged public func addToFilms(_ values: NSSet)

    @objc(removeFilms:)
    @NSManaged public func removeFromFilms(_ values: NSSet)

}

// MARK: Generated accessors for people
extension Specie {

    @objc(addPeopleObject:)
    @NSManaged public func addToPeople(_ value: Person)

    @objc(removePeopleObject:)
    @NSManaged public func removeFromPeople(_ value: Person)

    @objc(addPeople:)
    @NSManaged public func addToPeople(_ values: NSSet)

    @objc(removePeople:)
    @NSManaged public func removeFromPeople(_ values: NSSet)

}

//
//  Deck+CoreDataClass.swift
//  CoreDataExampleSwift
//
//  Created by Andrew Riznyk on 7/30/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

import Foundation
import CoreData


@objc(Deck)
public class Deck: NSManagedObject {

    @NSManaged public var deckID: Int64
    @NSManaged public var name: Int64
    @NSManaged public var cards: NSSet?
    
    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)
    
    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)
    
    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)
    
    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)
}

extension Deck: ManagedObjectType {
    static let entityName = "Deck"
}

//
//  Card+CoreDataClass.swift
//  CoreDataExampleSwift
//
//  Created by Andrew Riznyk on 7/30/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectType {
    static var entityName: String { get }
}

@objc(Card)
public class Card: NSManagedObject {

    @NSManaged public var cardID: Int64
    @NSManaged public var deck_id: Int64
    @NSManaged public var number: Int32
    @NSManaged public var type: Int32
    @NSManaged public var deck: Deck?
    @NSManaged public var random: String?
}

extension Card: ManagedObjectType {
    static let entityName = "Card"
}

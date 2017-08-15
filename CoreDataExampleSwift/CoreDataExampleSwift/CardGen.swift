//
//  CardGen.swift
//  CoreDataExampleSwift
//
//  Created by Andrew Riznyk on 7/30/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

import UIKit

struct CardGen {
    static let deckCount : Int = 10000
    
    static func randomCardGenerator() -> NSMutableDictionary {
        let cardID  =  Int(arc4random()) % (deckCount * 4 * 14)
        let cardNumber = cardID % 14
        let cardType = (cardID/14) % 4
        let cardDeckID = cardID / (4 * 14)
        
        let card = NSMutableDictionary()
        card.setValue(cardID, forKey: "cardID")
        card.setValue(cardType, forKey: "cardType")
        card.setValue(cardNumber, forKey: "cardNumber")
        card.setValue(cardDeckID, forKey: "deckID")
        
        return card
    }
    
    static func createDecksAndCardsJson() -> Data {
        var list = [AnyObject]()
        
        var cardID = 0
        for x in 0..<deckCount {
            var deck = [String:AnyObject]()
            deck["deckID"] = NSNumber(value:x)
            deck["deckName"] = NSNumber(value:x)
            var cardList = [AnyObject]()
            for y in 0..<4 {
                for z in 0..<14 {
                    var card = [String:NSNumber]()
                    card["type"] = NSNumber(value:y)
                    card["cardNumber"] = NSNumber(value:z)
                    card["cardID"] = NSNumber(value:cardID)
                    card["deckID"] = NSNumber(value:x)
                    cardList.append(card as AnyObject)
                    cardID += 1
                }
            }
            deck["cards"] = cardList as AnyObject
            list.append(deck as AnyObject)
        }
        do {
            let data : Data = try JSONSerialization.data(withJSONObject: list, options:  JSONSerialization.WritingOptions.prettyPrinted)
//            let s : String = String.init(data: data, encoding: String.Encoding.utf8)!
//            print(s)
            return data
        } catch {
            
        }
        return Data()
    }

}

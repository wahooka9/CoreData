//
//  RepoController.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card+CoreDataProperties.h"

@interface RepoControllerSingle : NSObject
+(Deck*)makeDeck;
+(Card*)makeCard;

+(Deck*) deckWithID:(int)deckValueID;
+(Card*) cardWithID:(long)cardID;

+(Deck*) deckWithObjectID:(NSManagedObjectID*)deckValueID;
+(Card*) cardWithObjectID:(NSManagedObjectID*)cardID;

+(void) removeObject:(id)obj;
+(void) batchDelete;

+(void) save;
+(void) freeMemory;
+(long) getObjectCount;
+(void) refreshObject:(NSManagedObject*)mo;

+(NSFetchedResultsController*)getCards;
+(NSArray*) getCardObjects;
+(NSArray*)getDecks;

+(Deck*)getDeck:(long)deckID;

@end

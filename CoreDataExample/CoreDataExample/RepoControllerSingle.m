//
//  RepoController.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "RepoControllerSingle.h"
#import "SingleCoreD.h"
#import "Card+CoreDataProperties.h"
#import "Deck+CoreDataProperties.h"

@implementation RepoControllerSingle

+(Card*)makeCard {
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
//    Card *card = [Card insertIntoContext:moc];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:moc];
    Card *card = [[Card alloc] initWithEntity:entity  insertIntoManagedObjectContext:nil];
    [moc insertObject:card];
    
    return card;
}

+(Card*) cardWithID:(long)cardID {
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"cardID == %ld", cardID]];
    [request setFetchLimit:1];
    NSArray *objects = [moc executeFetchRequest:request error:NULL];
    if (objects.count > 0){
        return objects.firstObject;
    } else {
        Card *card = [self makeCard];
        [card setCardID:cardID];
        return card;
    }
}

+(Card*) cardWithObjectID:(NSManagedObjectID*)cardID {
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    return [moc existingObjectWithID:cardID error:nil];
}

+(Deck*)makeDeck {
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    //Deck *deck = [Deck insertIntoContext:moc];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:moc];
    Deck *deck = [[Deck alloc] initWithEntity:entity  insertIntoManagedObjectContext:nil];
    [moc insertObject:deck];
    return deck;
}

+(Deck*) deckWithID:(int)deckValueID {
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"deckID == %ld", deckValueID]];
    NSArray *objects = [moc executeFetchRequest:request error:NULL];
    if (objects.count > 0){
        return objects.firstObject;
    } else {
        Deck *deck = [self makeDeck];
        [deck setDeckID:deckValueID];
        return deck;
    }
}
+(Deck*) deckWithObjectID:(NSManagedObjectID*)deckValueID {
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    return [moc existingObjectWithID:deckValueID error:nil];
}


+(NSFetchedResultsController*)getCards {
     NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
     [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"deck.deckID" ascending:true], [[NSSortDescriptor alloc] initWithKey:@"type" ascending:true], [[NSSortDescriptor alloc] initWithKey:@"number" ascending:true]]];
     [request setFetchBatchSize:20];
     NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
     NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
     [frc performFetch:nil];
     return frc;
}

+(NSArray*) getCardObjects {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"cardID" ascending:true]]];
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    NSArray *objects = [moc executeFetchRequest:request error:NULL];
    return objects;
}

+(NSArray*)getDecks {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"deckID" ascending:true]]];
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    NSArray *objects = [moc executeFetchRequest:request error:NULL];
    return objects;
}

+(Deck*)getDeck:(long)deckID {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"deckID == %ld", deckID]];
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    NSArray *objects = [moc executeFetchRequest:request error:NULL];
    return objects.firstObject;
}

+(Card*)getCard:(long)cardID {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"cardID == %ld", cardID]];
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    NSArray *objects = [moc executeFetchRequest:request error:NULL];
    return objects.firstObject;
}

+(void) removeObject:(id)obj {
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    [moc deleteObject:obj];
}

+(void) batchDelete {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
    NSBatchDeleteRequest *req = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    NSManagedObjectContext *moc = [[SingleCoreD sharedInstance] managedObjectContext];
    NSBatchDeleteResult *objects = [moc executeRequest:req error:NULL];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:NSDeletedObjectsKey,[objects result], nil];
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:dict intoContexts:@[moc]];
}

+(void) save {
       [[SingleCoreD sharedInstance] saveContext];
}

+(long) getObjectCount {
    NSManagedObjectContext *moc  = [[SingleCoreD sharedInstance] managedObjectContext];
    return [[moc registeredObjects] count];
}

+(void) refreshObject:(NSManagedObject*)mo {
    NSManagedObjectContext *moc  = [[SingleCoreD sharedInstance] managedObjectContext];
    [moc refreshObject:mo mergeChanges:NO];
}

+(void) freeMemory {
    NSManagedObjectContext *moc  = [[SingleCoreD sharedInstance] managedObjectContext];
    while (moc) {
        [moc reset];
        moc = [moc parentContext];
    }
}

@end

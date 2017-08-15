//
//  RepoControllerParentChild.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/21/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "RepoControllerParentChild.h"
#import <CoreData/CoreData.h>
#import "ParentChildCoreD.h"
#import "Card+CoreDataProperties.h"
#import "Deck+CoreDataProperties.h"

@implementation RepoControllerParentChild

+(Card*)makeCardinContext:(NSManagedObjectContext*)moc {
    Card *card = [Card insertIntoContext:moc];
    return card;
}

+(Card*) cardWithID:(long)cardID inContext:(NSManagedObjectContext*)moc {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"cardID == %ld", cardID]];
    Card *object = [[moc executeFetchRequest:request error:NULL] firstObject];
    if (object != nil){
        return object;
    } else {
        Card *card = [self makeCardinContext:moc];
        [card setCardID:cardID];
        return card;
    }
}

+(Deck*)makeDeckinContext:(NSManagedObjectContext*)moc {
    Deck *deck = [Deck insertIntoContext:moc];
    return deck;
}

+(Deck*) deckWithID:(int)deckValueID inContext:(NSManagedObjectContext*)moc {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"deckID == %ld", deckValueID]];
    NSArray *objects = [moc executeFetchRequest:request error:NULL];
    if (objects.count > 0){
        return objects.firstObject;
    } else {
        Deck *deck = [self makeDeckinContext:moc];
        [deck setDeckID:deckValueID];
        return deck;
    }
}

-(NSFetchedResultsController*)getCards {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"deck.deckID" ascending:true], [[NSSortDescriptor alloc] initWithKey:@"type" ascending:true], [[NSSortDescriptor alloc] initWithKey:@"number" ascending:true]]];
    [request setFetchBatchSize:20];
    NSManagedObjectContext *moc = [[ParentChildCoreD sharedInstance] managedObjectContext];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    [frc performFetch:nil];
    return frc;
}

-(void)deleteAll {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
    NSManagedObjectContext *moc = [[ParentChildCoreD sharedInstance] writeManagedObjectContext];
    [moc performBlock:^{
        NSArray *objects = [moc executeFetchRequest:request error:NULL];
        for (NSManagedObject *mo in objects){
            [moc deleteObject:mo];
        }
        
        [[ParentChildCoreD sharedInstance] saveContext:moc];
        [self.delegate runningFinished:[NSDate date]];
    }];
    
}


-(void) removeObject:(id)obj {
    NSManagedObjectContext *moc = [[ParentChildCoreD sharedInstance] writeManagedObjectContext];
    [moc performBlock:^{
        [moc deleteObject:obj];
    }];
}


-(void) parseDecksAndCards:(NSArray*) data withBatches:(int)size {
    NSManagedObjectContext *moc = [[ParentChildCoreD sharedInstance] writeManagedObjectContext];
    
    [moc performBlock:^{
        int count = 0;
    for (NSDictionary *deck in data){
        int deckValueID = [[deck objectForKey:@"deckID"] intValue];
        int deckValueName = [[deck objectForKey:@"deckName"] intValue];
        
        Deck *contextDeck = [RepoControllerParentChild makeDeckinContext:moc];// [RepoControllerParentChilddeckWithID:deckValueID inContext:moc];
        [contextDeck setName:deckValueName];
        [contextDeck setDeckID:deckValueID];
        
        NSArray *cards = [deck objectForKey:@"cards"];
        for (NSDictionary *card in cards){
            long cardID = [[card objectForKey:@"cardID"] longValue];
            long cardType = [[card objectForKey:@"cardType"]  longValue];
            long cardNumber = [[card objectForKey:@"cardNumber"]  longValue];
            int deckID = [[card objectForKey:@"deckID"] intValue];
            
            Card *contextCard = [RepoControllerParentChild makeCardinContext:moc];// [RepoControllerParentChild cardWithID:cardID inContext:moc];
            [contextCard setDeckID:deckID];
            [contextCard setCardID:cardID];
            [contextCard setType:cardType];
            [contextCard setNumber:cardNumber];
            
            [contextCard setDeck:contextDeck];
            [contextDeck addCardsObject:contextCard];
            count +=1;
            if (size != 0 && count % (size * 10) == 0){
                [[ParentChildCoreD sharedInstance] saveContext:moc];
            }
        }
    }
        [[ParentChildCoreD sharedInstance] saveContext:moc];
        [self.delegate runningFinished:[NSDate date]];
    }];

}

-(void)removeCards:(NSArray*)cards {
    NSManagedObjectContext *moc = [[ParentChildCoreD sharedInstance] writeManagedObjectContext];
    
    [moc performBlock:^{
        for (int i = 0; i< cards.count;i++) {
            Card *card = [RepoControllerParentChild cardWithID:[cards[i] longValue] inContext:moc];
            [moc deleteObject:card];
        }
        [[ParentChildCoreD sharedInstance] saveContext:moc];
        [self.delegate runningFinished:[NSDate date]];
    }];
}

@end

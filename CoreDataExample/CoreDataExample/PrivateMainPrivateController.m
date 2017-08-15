//
//  PrivateMainPrivateController.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/25/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "PrivateMainPrivateController.h"
#import "PrivateMainPrivate.h"

#import "Card+CoreDataProperties.h"
#import "Deck+CoreDataProperties.h"

@implementation PrivateMainPrivateController


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
    NSManagedObjectContext *moc = [[PrivateMainPrivate sharedInstance] managedObjectContext];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    [frc performFetch:nil];
    return frc;
}

-(void)deleteAll {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Deck"];
    NSManagedObjectContext *moc = [[PrivateMainPrivate sharedInstance] writeManagedObjectContext];
    [moc performBlock:^{
        NSArray *objects = [moc executeFetchRequest:request error:NULL];
        for (NSManagedObject *mo in objects){
            [moc deleteObject:mo];
        }
        
        [[PrivateMainPrivate sharedInstance] save:moc];
        [self.delegate runningFinished:[NSDate date]];
    }];
    
}


-(void) removeObject:(id)obj {
    NSManagedObjectContext *moc = [[PrivateMainPrivate sharedInstance] writeManagedObjectContext];
    [moc performBlock:^{
        [moc deleteObject:obj];
    }];
}


-(void) parseDecksAndCards:(NSArray*) data withBatches:(int)size {
    
    NSManagedObjectContext *moc = [[PrivateMainPrivate sharedInstance] writeManagedObjectContext];

    [moc performBlock:^{
        int count = 0;
        for (NSDictionary *deck in data){
//            int deckValueID = [[deck objectForKey:@"deckID"] intValue];
//            int deckValueName = [[deck objectForKey:@"deckName"] intValue];
//            
//            Deck *contextDeck = [PrivateMainPrivateController makeDeckinContext:moc];// [PrivateMainPrivateController deckWithID:deckValueID inContext:moc];
//            [contextDeck setName:deckValueName];
//            [contextDeck setDeckID:deckValueID];
            
            NSArray *cards = [deck objectForKey:@"cards"];
            for (NSDictionary *card in cards){
                long cardID = [[card objectForKey:@"cardID"] longValue];
                long cardType = [[card objectForKey:@"cardType"]  longValue];
                long cardNumber = [[card objectForKey:@"cardNumber"]  longValue];
                int deckID = [[card objectForKey:@"deckID"] intValue];
                
                Card *contextCard = [PrivateMainPrivateController makeCardinContext:moc];// [RepoControllerParentChild cardWithID:cardID inContext:moc];
                [contextCard setDeckID:deckID];
                [contextCard setCardID:cardID];
                [contextCard setType:cardType];
                [contextCard setNumber:cardNumber];
                
                //[contextCard setDeck:contextDeck];
                //[contextDeck addCardsObject:contextCard];
                count +=1;
                if (size != 0 && count % (size * 100) == 0){
                    [[PrivateMainPrivate sharedInstance] save:moc];
                }
            }
        }
        [[PrivateMainPrivate sharedInstance] save:moc];
        [self.delegate runningFinished:[NSDate date]];
    }];
}



-(void) memorySaveParseDecksAndCards:(NSArray*) data {
    int size = 100;
    for (int i = 0; i < 1000; i += size){
        [self parseDecksAndCards:[data subarrayWithRange:NSMakeRange(i, size)]];
    }
    [self.delegate runningFinished:[NSDate date]];
}

-(void) parseDecksAndCards:(NSArray*) data{
    
        
    
    NSManagedObjectContext *moc = [[PrivateMainPrivate sharedInstance] writeManagedObjectContext];
    
    [moc performBlock:^{
        for (NSDictionary *deck in data){
            @autoreleasepool {
            int deckValueID = [[deck objectForKey:@"deckID"] intValue];
            int deckValueName = [[deck objectForKey:@"deckName"] intValue];
            
            Deck *contextDeck = [PrivateMainPrivateController makeDeckinContext:moc];// [PrivateMainPrivateController deckWithID:deckValueID inContext:moc];
            [contextDeck setName:deckValueName];
            [contextDeck setDeckID:deckValueID];
            NSArray *cards = [deck objectForKey:@"cards"];
            for (NSDictionary *card in cards){
                @autoreleasepool {
                long cardID = [[card objectForKey:@"cardID"] longValue];
                long cardType = [[card objectForKey:@"cardType"]  longValue];
                long cardNumber = [[card objectForKey:@"cardNumber"]  longValue];
                int deckID = [[card objectForKey:@"deckID"] intValue];
                Card *contextCard = [PrivateMainPrivateController makeCardinContext:moc];// [RepoControllerParentChild cardWithID:cardID inContext:moc];
                [contextCard setDeckID:deckID];
                [contextCard setCardID:cardID];
                [contextCard setType:cardType];
                [contextCard setNumber:cardNumber];
                
                [contextCard setDeck:contextDeck];
                [contextDeck addCardsObject:contextCard];
                }
            }
            }
        }
        [[PrivateMainPrivate sharedInstance] save:moc];
        [moc reset];
        [self.delegate runningFinished:[NSDate date]];
    }];
}





-(void)removeCards:(NSArray*)cards {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSManagedObjectContext *moc = [[PrivateMainPrivate sharedInstance] writeManagedObjectContext];
    
    [moc performBlock:^{
        for (int i = 0; i< cards.count;i++) {
            Card *card = [PrivateMainPrivateController cardWithID:[cards[i] longValue] inContext:moc];
            [moc deleteObject:card];
        }
        [[PrivateMainPrivate sharedInstance] save:moc];
        [self.delegate runningFinished:[NSDate date]];
    }];
    });
}


@end

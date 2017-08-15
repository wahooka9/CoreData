//
//  fakeNetworkParser.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/23/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "fakeNetworkParser.h"
#import "RepoControllerSingle.h"
#import "Card+CoreDataProperties.h"
#import "Deck+CoreDataProperties.h"

#import "SingleCoreD.h"

@implementation fakeNetworkParser

-(instancetype)init {
    self = [super init];
    if (self) {
        self.cardCache = [[NSMutableDictionary alloc] init];
        self.deckCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)parseData:(NSArray*)decks {
    dispatch_async(dispatch_get_main_queue(), ^{

        for (NSDictionary *deck in decks){

            int deckValueID = [[deck objectForKey:@"deckID"] intValue];
            int deckValueName = [[deck objectForKey:@"deckName"] intValue];
            
            Deck *contextDeck;
            contextDeck = [RepoControllerSingle makeDeck];

            [contextDeck setName:deckValueName];
            [contextDeck setDeckID:deckValueID];

            NSArray *cards = [deck objectForKey:@"cards"];
            for (NSDictionary *card in cards){
                long cardID = [[card objectForKey:@"cardID"] longValue];
                long cardType = [[card objectForKey:@"cardType"]  longValue];
                long cardNumber = [[card objectForKey:@"cardNumber"]  longValue];
                int deckID = [[card objectForKey:@"deckID"] intValue];
                Card *contextCard;
                    contextCard = [RepoControllerSingle makeCard];
                [contextCard setDeckID:deckID];
                [contextCard setCardID:cardID];
                [contextCard setType:cardType];
                [contextCard setNumber:cardNumber];
                [contextCard setDeck:contextDeck];
                [contextDeck addCardsObject:contextCard];
            }
        }
        [RepoControllerSingle save];
        [self.delegate runtimeDate:[NSDate date]];
    });

}

-(void)parseDataFaster:(NSArray*)decks {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *cardList = [RepoControllerSingle getCardObjects];
        NSArray *deckList = [RepoControllerSingle getDecks];
        
        int deckPosistion = 0;
        
        for (NSDictionary *deck in decks){
            
            int deckValueID = [[deck objectForKey:@"deckID"] intValue];
            int deckValueName = [[deck objectForKey:@"deckName"] intValue];
            
            Deck *contextDeck;
            if ([deckList count] > deckPosistion){
            while ([[deckList objectAtIndex:deckPosistion] deckID] < deckValueID){
                deckPosistion += 1;
            }
            
            if ([[deckList objectAtIndex:deckPosistion] deckID] == deckValueID){
                contextDeck = [deckList objectAtIndex:deckPosistion];
            } else {
                contextDeck = [RepoControllerSingle makeDeck];
            }
            
            } else {
                contextDeck = [RepoControllerSingle makeDeck];
            }
            
            [contextDeck setName:deckValueName];
            [contextDeck setDeckID:deckValueID];
            
            NSArray *cards = [deck objectForKey:@"cards"];
            int cardPosistion = 0;
            for (NSDictionary *card in cards){
                long cardID = [[card objectForKey:@"cardID"] longValue];
                long cardType = [[card objectForKey:@"cardType"]  longValue];
                long cardNumber = [[card objectForKey:@"cardNumber"]  longValue];
                int deckID = [[card objectForKey:@"deckID"] intValue];
                
                Card *contextCard;
                
                if ([cardList count] > cardPosistion){
                while ([[cardList objectAtIndex:cardPosistion] cardID] < cardID){
                    cardPosistion += 1;
                }
                
                if ([[cardList objectAtIndex:cardPosistion] cardID] == cardID){
                    contextCard = [cardList objectAtIndex:cardPosistion];
                } else {
                    contextCard = [RepoControllerSingle makeCard];
                }
                } else {
                    contextCard = [RepoControllerSingle makeCard];
                }
                
                [contextCard setDeckID:deckID];
                [contextCard setCardID:cardID];
                [contextCard setType:cardType];
                [contextCard setNumber:cardNumber];
                [contextCard setDeck:contextDeck];
                [contextDeck addCardsObject:contextCard];
            }
        }
        [RepoControllerSingle save];
        [self.delegate runtimeDate:[NSDate date]];
    });
    
}


@end

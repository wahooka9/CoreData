//
//  Database.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/26/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DeckSQL.h"
#import "CardSQL.h"

@interface Database : NSObject {
    sqlite3 *_database;
    NSString *databasePath;
}

@property BOOL isOpen;

+(Database*)sharedInstance;
-(BOOL)createDB;
-(DeckSQL*) getDeckByID:(long)deck_id;
-(CardSQL*) getCardByID:(long)card_id;

-(void) saveDeck:(DeckSQL*)deck;
-(void) saveCard:(CardSQL*)card;
-(void) saveDecks:(NSArray*)decks;
-(void) saveCards:(NSArray*)cards;

-(BOOL)openDataBase;
-(void)closeDataBase;

-(void)startBulkSave;
-(void)endBulkSave;
    
-(NSArray*) getCardList;
-(long) getCardCount;
//-(NSArray*)scrollDown;
//-(NSArray*)scrollUp;

-(NSArray*)scrollUp:(int)deckID type:(int)type number:(int)number;
-(NSArray*)scrollDown:(int)deckID type:(int)type number:(int)number;

@end

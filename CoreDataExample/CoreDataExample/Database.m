//
//  Database.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/26/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "Database.h"


static Database *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation Database

+(Database*)sharedInstance{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[super allocWithZone:NULL] init];
        [sharedObject createDB];
        [sharedObject setIsOpen:false];
    });
    return sharedObject;
}

-(BOOL) createDB {
    NSString *cacheDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true);
    cacheDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:[cacheDir stringByAppendingPathComponent:@"deck.db"]];
    BOOL isSuccessful = true;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:databasePath] == false){
        isSuccessful = [self createDeckTable] && [self createCardTable];
    }
    return isSuccessful;
}

-(BOOL) createDeckTable {
    const char *sql_stmt = "create table if not exists deck (id NUMERIC primary key, name NUMERIC)";
    return [self sqliteExe:sql_stmt];
}

-(BOOL) createCardTable {
    const char *sql_stmt = "create table if not exists card (id NUMERIC primary key, deck_id NUMERIC, number NUMERIC, type NUMERIC)";
    const char *sql_index_stmt = "create index cardOrder on card (deck_id, type, number)";
    return [self sqliteExe:sql_stmt] && [self sqliteExe:sql_index_stmt];
}
//////////////////////////////////

-(NSArray*)scrollDown:(int)deckID type:(int)type number:(int)number {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([self openDataBase])
    {
        NSString *querySQL = [NSString stringWithFormat: @"select id, deck_id, number, type from card where deck_id < %i AND type < %i AND number < %i  order by deck_id, type, number DESC limit 14", deckID, type, number];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                CardSQL *card = [[CardSQL alloc] init];
                long cardID = sqlite3_column_int64(statement, 0);
                long deck_id = sqlite3_column_int64(statement, 1);
                int number = sqlite3_column_int(statement, 2);
                int type = sqlite3_column_int(statement, 3);
                
                [card setCardID:cardID];
                [card setDeck_id:deck_id];
                [card setNumber:number];
                [card setType:type];
                
                [result addObject:card];
            }
        }
    }
    sqlite3_reset(statement);
    return result;
}

-(NSArray*)scrollUp:(int)deckID type:(int)type number:(int)number {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([self openDataBase])
    {
        NSString *querySQL = [NSString stringWithFormat: @"select id, deck_id, number, type from card where deck_id > %i AND type > %i AND number > %i order by deck_id, type, number ASC limit 14", deckID, type, number];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                CardSQL *card = [[CardSQL alloc] init];
                long cardID = sqlite3_column_int64(statement, 0);
                long deck_id = sqlite3_column_int64(statement, 1);
                int number = sqlite3_column_int(statement, 2);
                int type = sqlite3_column_int(statement, 3);
                
                [card setCardID:cardID];
                [card setDeck_id:deck_id];
                [card setNumber:number];
                [card setType:type];
                
                [result addObject:card];
            }
        }
    }
    sqlite3_reset(statement);
    return result;
}

//////////////////////////////////

-(DeckSQL*) getDeckByID:(long)deck_id {
    DeckSQL *deck = [[DeckSQL alloc] init];
    
    if ([self openDataBase])
    {
        NSString *querySQL = [NSString stringWithFormat: @"select id, name from deck where id=\"%ld\"", deck_id];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                long deckID = sqlite3_column_int64(statement, 0);
                long name = sqlite3_column_int64(statement, 1);
                
                [deck setDeckID:deckID];
                [deck setName:name];
            } else{
                //NSLog(@"Not found");
            }
        }
        sqlite3_reset(statement);
    }
    return deck;
}

-(CardSQL*) getCardByID:(long)card_id {
    CardSQL *card = [[CardSQL alloc] init];

    if ([self openDataBase])
    {
        NSString *querySQL = [NSString stringWithFormat: @"select id, deck_id, number, type from card where id=\"%ld\"", card_id];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                long cardID = sqlite3_column_int64(statement, 0);
                long deck_id = sqlite3_column_int64(statement, 1);
                int number = sqlite3_column_int(statement, 2);
                int type = sqlite3_column_int(statement, 3);
                
                [card setCardID:cardID];
                [card setDeck_id:deck_id];
                [card setNumber:number];
                [card setType:type];
            } else{
                //NSLog(@"Not found");
            }
        }
        sqlite3_reset(statement);
    }
    return card;
}


//////////////////////////////////

-(void) saveDeck:(DeckSQL*)deck {
    if ([self openDataBase])
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into deck (id ,name) values (\"%ld\",\"%ld\")", deck.deckID, deck.name];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_exec(database, insert_stmt, NULL, NULL, NULL);
    }
    
}

-(void) saveCard:(CardSQL*)card {
    if ([self openDataBase])
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into card (id ,deck_id, number, type) values (\"%ld\",\"%ld\",\"%i\",\"%i\")", card.cardID, card.deck_id, card.number, card.type];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_exec(database, insert_stmt, NULL, NULL, NULL);
    }
}

-(void) saveCards:(NSArray*)cards {
    if ([self openDataBase])
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO card (id, deck_id, number, type) values (?, ?, ?, ?)"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        for (NSDictionary *card in cards){
            sqlite3_bind_int64(statement, 1, [[card objectForKey:@"cardID"] longValue]);
            sqlite3_bind_int64(statement, 2, [[card objectForKey:@"deckID"] longValue]);
            sqlite3_bind_int(statement, 3, [[card objectForKey:@"cardNumber"]  intValue]);
            sqlite3_bind_int(statement, 4, [[card objectForKey:@"cardType"]  intValue]);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
               // NSLog(@"failed commit");
            }
            sqlite3_reset(statement);
        }
    }
}

-(void) saveDecks:(NSArray*)decks {
    if ([self openDataBase])
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into deck (id ,name) values (?1, ?2)"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        for (NSDictionary *deck in decks){
            sqlite3_bind_int(statement, 1, [[deck objectForKey:@"deckID"] intValue]);
            sqlite3_bind_int(statement, 2, [[deck objectForKey:@"deckName"] intValue]);
        
            if (sqlite3_step(statement) != SQLITE_DONE) {
               // NSLog(@"failed commit");
            }
            sqlite3_reset(statement);
        }
    }
}


///////////////////////////////////
-(NSArray*) getCardList {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([self openDataBase])
    {
        NSString *querySQL = [NSString stringWithFormat: @"select id, deck_id, number, type from card order by deck_id, type, number ASC"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                CardSQL *card = [[CardSQL alloc] init];
                long cardID = sqlite3_column_int64(statement, 0);
                long deck_id = sqlite3_column_int64(statement, 1);
                int number = sqlite3_column_int(statement, 2);
                int type = sqlite3_column_int(statement, 3);
                
                [card setCardID:cardID];
                [card setDeck_id:deck_id];
                [card setNumber:number];
                [card setType:type];

                [result addObject:card];
            }
        }
    }
    sqlite3_reset(statement);
    return result;
}

-(long) getCardCount {
    long cardCount = 0;
    if ([self openDataBase])
    {
        NSString *querySQL = [NSString stringWithFormat: @"select count(id) from card"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                cardCount = sqlite3_column_int64(statement, 0);
            }
        }
    }
    sqlite3_finalize(statement);
    return cardCount;
}


///////////////////////////////////

-(void)startBulkSave {
    if ([self openDataBase]){
        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
    }
}

-(void)endBulkSave {
    char* errorMessage;
    if ([self openDataBase]){
        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
        sqlite3_finalize(statement);
    }
}


-(BOOL)openDataBase {
    if (self.isOpen){
        return true;
    }
    const char *dbpath = [databasePath UTF8String];
    self.isOpen = (sqlite3_open(dbpath, &database) == SQLITE_OK);
    return self.isOpen;
}

-(void)closeDataBase {
    sqlite3_close(database);
    self.isOpen = false;
}

-(BOOL) sqliteExe:(const char*) sql_stmt {
    char *errMsg;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            NSLog(@"Failed to create table %s", errMsg);
            return false;
        }
        sqlite3_close(database);
        return  true;
    }
    return false;
}


@end

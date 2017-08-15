//
//  CardGenerator.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/21/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "CardGenerator.h"
#import "Deck+CoreDataProperties.h"
#import "Card+CoreDataProperties.h"

@implementation CardGenerator

-(instancetype)init {
    self = [super init];
    if (self){
        self.deckCount = 100;
    }
    return self;
}

-(NSDictionary *) randomCardGenerator {
    NSInteger cardID = arc4random() % (self.deckCount * 4 * 14);
    NSInteger cardNumber = cardID % 14;
    NSInteger cardType = (cardID / 14) % 4 ;
    NSInteger cardDeckID = cardID / (4 * 14);
    
    NSMutableDictionary *card = [[NSMutableDictionary alloc] init];
    [card setValue:[NSNumber numberWithInt:(int)cardNumber] forKey: @"cardNumber"];
    [card setValue:[NSNumber numberWithInt:(int)cardType] forKey: @"cardType"];
    [card setValue:[NSNumber numberWithInt:(int)cardID] forKey: @"cardID"];
    [card setValue:[NSNumber numberWithInt:(int)cardDeckID] forKey: @"deckID"];
    
    return card;
}


-(NSData*) createCardsJson {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    long cardID = 0;
    for (int i = 0; i < self.deckCount; i++){
        NSNumber *deckID = [NSNumber numberWithInt:i];
        for (int j = 0; j<4; j++){
            for (int k = 0; k<14; k++){
                NSMutableDictionary *card = [[NSMutableDictionary alloc] init];
                NSNumber *cardNumber = [NSNumber numberWithInt:k];
                [card setValue:cardNumber forKey: @"cardNumber"];
                NSNumber *cardType = [NSNumber numberWithInt:j];
                [card setValue:cardType forKey: @"cardType"];
                NSNumber *cardIdent = [NSNumber numberWithLong:cardID];
                [card setValue:cardIdent forKey: @"cardID"];
                [card setValue:deckID forKey: @"deckID"];
                [list addObject:card];
                cardID +=1;
            }
        }
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:nil];
    return jsonData;
}

-(NSData*) createDecksJson {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.deckCount; i++){
        NSMutableDictionary *deck = [[NSMutableDictionary alloc] init];
        NSNumber *deckID = [NSNumber numberWithInt:i];
        [deck setValue:deckID forKey: @"deckID"];
        [deck setValue:deckID forKey: @"deckName"];
        [list addObject:deck];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:nil];
    return jsonData;
}

-(NSData*) createDecksAndCardsJson {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    long cardID = 0;
    for (int i = 0; i < self.deckCount; i++){
        NSMutableDictionary *deck = [[NSMutableDictionary alloc] init];
        NSNumber *deckID = [NSNumber numberWithInt:i];
        [deck setValue:deckID forKey: @"deckID"];
        [deck setValue:deckID forKey: @"deckName"];
        [deck setObject:[[NSMutableArray alloc] init] forKey:@"cards"];
        for (int j = 0; j<4; j++){
            for (int k = 0; k<14; k++){
                NSMutableDictionary *card = [[NSMutableDictionary alloc] init];
                NSNumber *cardNumber = [NSNumber numberWithInt:k];
                [card setValue:cardNumber forKey: @"cardNumber"];
                NSNumber *cardType = [NSNumber numberWithInt:j];
                [card setValue:cardType forKey: @"cardType"];
                NSNumber *cardIdent = [NSNumber numberWithLong:cardID];
                [card setValue:cardIdent forKey: @"cardID"];
                [card setValue:deckID forKey: @"deckID"];
                [[deck objectForKey:@"cards"] addObject:card];
                cardID +=1;
            }
        }
        [list addObject:deck];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:nil];
    //NSString *s = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //NSString *s = [NSString stringWithUTF8String:[jsonData bytes]];
    return jsonData;
}



@end

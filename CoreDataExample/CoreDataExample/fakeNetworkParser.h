//
//  fakeNetworkParser.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/23/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol timerDelegate <NSObject>
-(void)runtimeDate:(NSDate*)finishTime;
@end

@interface fakeNetworkParser : NSObject

@property (weak, nonatomic) id<timerDelegate> delegate;

@property (strong, nonatomic) NSMutableDictionary *deckCache;
@property (strong, nonatomic) NSMutableDictionary *cardCache;

-(void)parseData:(NSArray*)decks;
-(void)parseDataFaster:(NSArray*)decks;

@end

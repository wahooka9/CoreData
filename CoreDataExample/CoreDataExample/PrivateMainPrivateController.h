//
//  PrivateMainPrivateController.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/25/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol timerDelegate <NSObject>
-(void)runningFinished:(NSDate*)finshed;
@end

@interface PrivateMainPrivateController : NSObject
@property (weak, nonatomic) id<timerDelegate> delegate;
-(void)deleteAll;
-(NSFetchedResultsController*)getCards;
-(void) parseDecksAndCards:(NSArray*) data withBatches:(int)size;
-(void)removeCards:(NSArray*)cards;

-(void) memorySaveParseDecksAndCards:(NSArray*) data;
@end

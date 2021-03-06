//
//  Card+CoreDataClass.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Deck;

NS_ASSUME_NONNULL_BEGIN

@interface Card : NSManagedObject
+ (id) insertIntoContext:(NSManagedObjectContext*)context;
@end

NS_ASSUME_NONNULL_END

#import "Card+CoreDataProperties.h"

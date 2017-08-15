//
//  Deck+CoreDataClass.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

NS_ASSUME_NONNULL_BEGIN

@interface Deck : NSManagedObject
+ (id) insertIntoContext:(NSManagedObjectContext*)context;
@end

NS_ASSUME_NONNULL_END

#import "Deck+CoreDataProperties.h"

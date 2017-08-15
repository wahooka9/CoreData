//
//  Deck+CoreDataClass.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "Deck.h"
#import "Card.h"

@implementation Deck

- (NSString*) entityName {
    return @"Deck";
}

+ (NSString*) entityName {
    return @"Deck";
}

+ (id) insertIntoContext:(NSManagedObjectContext*)context {
    return [self insertNewObjectIntoContextHelper:context];
}

+ (id) insertNewObjectIntoContextHelper:(NSManagedObjectContext*)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext: context];
}


@end

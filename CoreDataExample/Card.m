//
//  Card+CoreDataClass.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "Card.h"
#import "Deck.h"

@implementation Card

- (NSString*) entityName {
    return @"Card";
}

+ (NSString*) entityName {
    return @"Card";
}

+ (id) insertIntoContext:(NSManagedObjectContext*)context {
    return [self insertNewObjectIntoContextHelper:context];
}

+ (id) insertNewObjectIntoContextHelper:(NSManagedObjectContext*)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext: context];
}


@end

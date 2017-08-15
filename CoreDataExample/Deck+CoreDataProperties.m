//
//  Deck+CoreDataProperties.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/25/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "Deck+CoreDataProperties.h"

@implementation Deck (CoreDataProperties)

+ (NSFetchRequest<Deck *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Deck"];
}

@dynamic deckID;
@dynamic name;
@dynamic cards;

@end

//
//  Deck+CoreDataProperties.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/25/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "Deck.h"


NS_ASSUME_NONNULL_BEGIN

@interface Deck (CoreDataProperties)

+ (NSFetchRequest<Deck *> *)fetchRequest;

@property (nonatomic) int32_t deckID;
@property (nonatomic) int32_t name;
@property (nullable, nonatomic, retain) NSSet<Card *> *cards;

@end

@interface Deck (CoreDataGeneratedAccessors)

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet<Card *> *)values;
- (void)removeCards:(NSSet<Card *> *)values;

@end

NS_ASSUME_NONNULL_END

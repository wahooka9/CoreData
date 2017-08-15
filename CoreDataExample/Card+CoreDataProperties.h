//
//  Card+CoreDataProperties.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/25/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "Card.h"


NS_ASSUME_NONNULL_BEGIN

@interface Card (CoreDataProperties)

+ (NSFetchRequest<Card *> *)fetchRequest;

@property (nonatomic) int64_t number;
@property (nonatomic) int16_t type;
@property (nonatomic) int32_t deckID;
@property (nonatomic) int64_t cardID;
@property (nullable, nonatomic, retain) Deck *deck;

@end

NS_ASSUME_NONNULL_END

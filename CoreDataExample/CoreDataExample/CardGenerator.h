//
//  CardGenerator.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/21/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardGenerator : NSObject

@property int deckCount;

-(NSData*) createDecksAndCardsJson;
-(NSDictionary*) randomCardGenerator;

@end

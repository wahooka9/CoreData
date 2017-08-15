//
//  FakeFetchController.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/28/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardSQL.h"
@interface FakeFetchController : NSObject

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSArray *data2;
@property (strong, nonatomic) NSIndexPath *last;

-(CardSQL*)getCardForIndexPath:(NSIndexPath*)indexPath;

@end

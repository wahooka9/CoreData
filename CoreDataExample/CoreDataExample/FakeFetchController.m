//
//  FakeFetchController.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/28/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "FakeFetchController.h"
#import "Database.h"

@implementation FakeFetchController

-(instancetype)init {
    self.data = [[Database sharedInstance] scrollUp:-1 type:-1 number:-1];
    return self;
}


-(CardSQL*)getCardForIndexPath:(NSIndexPath*)indexPath {
    // by 14 fetch
    int size = 14;
    int index = indexPath.row % size;
    if ((index == size-1) && indexPath.row != 0){
        if (indexPath.row % (size * 2) > size - 1 ) {
            CardSQL *card = self.data2[index];
                int deck = (int)card.deck_id - 1;
                int type = card.type;
                if (type == 3) {
                    deck ++;
                    type = -1;
                }
                self.data = [[Database sharedInstance] scrollUp:deck type:type number:-1];
        } else {
            CardSQL *card = self.data[index];
                int deck = (int)card.deck_id - 1;
                int type = card.type;
                if (type == 3) {
                    deck ++;
                    type = -1;
                }
                self.data2 = [[Database sharedInstance] scrollUp:deck type:type number:-1];
        }
    }
    self.last = indexPath;
    if (indexPath.row % (size * 2) > size - 1 ) {
        return self.data2[index];
    } else {
        return self.data[index];
    }
    
}

@end

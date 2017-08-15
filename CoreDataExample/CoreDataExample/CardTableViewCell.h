//
//  CardTableViewCell.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/21/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deckNumber;
@property (weak, nonatomic) IBOutlet UILabel *cardNumber;
@property (weak, nonatomic) IBOutlet UILabel *typeNumber;

@end

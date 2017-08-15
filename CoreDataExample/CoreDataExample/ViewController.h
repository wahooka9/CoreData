//
//  ViewController.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fakeNetworkParser.h"
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, timerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *frc;
@property (weak, nonatomic) IBOutlet UIStepper *stepperOutlet;

@property (strong,nonatomic) NSDate* methodStart;

@property (weak, nonatomic) IBOutlet UILabel *totalCountOutlet;
@property (weak, nonatomic) IBOutlet UILabel *timeOutlet;
@property (weak, nonatomic) IBOutlet UILabel *deleteRandomCount;


- (IBAction)deleteAction:(id)sender;
- (IBAction)createAction:(id)sender;

- (IBAction)stepperAction:(id)sender;

- (IBAction)deleteRandom:(id)sender;



@end


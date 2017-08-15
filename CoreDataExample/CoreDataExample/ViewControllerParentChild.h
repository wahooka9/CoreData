//
//  ViewControllerParentChild.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/21/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RepoControllerParentChild.h"

@interface ViewControllerParentChild : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, timerDelegate>

@property (strong, nonatomic) NSDate *methodStart;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *frc;

@property (weak, nonatomic) IBOutlet UIStepper *createStepperOutlet;
@property (weak, nonatomic) IBOutlet UIStepper *deleteStepperOutlet;
@property (weak, nonatomic) IBOutlet UILabel *createLabelOutlet;

@property (weak, nonatomic) IBOutlet UIButton *createAction;
- (IBAction)deleteStepperAction:(id)sender;

- (IBAction)createStepperAction:(id)sender;
- (IBAction)deleteSectionAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deleteAllAction;
@property (weak, nonatomic) IBOutlet UILabel *deleteCountOutlet;

@property (weak, nonatomic) IBOutlet UILabel *countOutlet;
@property (weak, nonatomic) IBOutlet UILabel *timeOutlet;
- (IBAction)deleteAll:(id)sender;

- (IBAction)createBatches:(id)sender;




@end

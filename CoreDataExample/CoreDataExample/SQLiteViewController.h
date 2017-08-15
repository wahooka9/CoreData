//
//  SQLiteViewController.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/26/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FakeFetchController.h"

@interface SQLiteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FakeFetchController *ffc;

@property (strong, nonatomic) NSDate *methodStart;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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


@property NSArray *data;

@end

//
//  ViewControllerParentChild.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/21/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "ViewControllerParentChild.h"
#import "CardTableViewCell.h"
#import "CardGenerator.h"
#import "RepoControllerParentChild.h"
#import "Deck+CoreDataProperties.h"
#import "Card+CoreDataProperties.h"

@interface ViewControllerParentChild ()
@property CardGenerator *cg;
@property RepoControllerParentChild *rcpc;
@end

@implementation ViewControllerParentChild
@synthesize cg;
@synthesize rcpc;

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cell = [UINib nibWithNibName:@"CardTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"Cell"];
    cg = [[CardGenerator alloc] init];
    rcpc = [[RepoControllerParentChild alloc] init];
    rcpc.delegate = self;
    self.frc = [rcpc getCards];
    //[self.frc setDelegate:self];
    
    [self prefersStatusBarHidden];
    
    self.createStepperOutlet.value = 0;
    self.createStepperOutlet.maximumValue = 50;
    self.createStepperOutlet.minimumValue = 0;
    self.createStepperOutlet.stepValue = 10;
    
    self.deleteStepperOutlet.value = 100;
    self.deleteStepperOutlet.minimumValue = 0;
    self.deleteStepperOutlet.maximumValue = 1000;
    self.deleteStepperOutlet.stepValue = 20;
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) makeCardsSingle {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* data = [cg createDecksAndCardsJson];
        NSArray *decks = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        self.methodStart = [NSDate date];
        [rcpc parseDecksAndCards:decks withBatches:self.createStepperOutlet.value];
    });
}


-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.countOutlet.text = [NSString stringWithFormat:@"%i", (int)self.frc.sections[section].numberOfObjects];
    return self.frc.sections[section].numberOfObjects;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Card *card = [self.frc objectAtIndexPath:indexPath];
    cell.cardNumber.text = [NSString stringWithFormat:@"%ld",(long)[card number]];
    cell.deckNumber.text = [NSString stringWithFormat:@"%d",[[card deck] deckID]];
    cell.typeNumber.text = [NSString stringWithFormat:@"%hd",[card type]];
    return cell;
}

-(void)runningFinished:(NSDate *)finshed {
    NSTimeInterval executionTime = [finshed timeIntervalSinceDate:self.methodStart];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeOutlet.text = [NSString stringWithFormat:@"%.02f",executionTime];
        self.frc = [rcpc getCards];
        [self.tableView reloadData];
    });
}

- (IBAction)deleteStepperAction:(id)sender {
    self.deleteCountOutlet.text = [NSString stringWithFormat:@"%i", (int)self.deleteStepperOutlet.value];
}

- (IBAction)createStepperAction:(id)sender {
    self.createLabelOutlet.text = [NSString stringWithFormat:@"%i", (int)self.createStepperOutlet.value];
}

- (IBAction)deleteSectionAction:(id)sender {
    self.methodStart = [NSDate date];
    NSMutableArray *cards = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.deleteStepperOutlet.value; i++){
        [cards addObject:[NSNumber numberWithLong:[[[cg randomCardGenerator] objectForKey:@"cardID"]longValue]]];
    }
    [rcpc removeCards:cards];
}

- (IBAction)deleteAll:(id)sender {
    self.methodStart = [NSDate date];
    [rcpc  deleteAll];
}

- (IBAction)createBatches:(id)sender {
    [self makeCardsSingle];
}
@end

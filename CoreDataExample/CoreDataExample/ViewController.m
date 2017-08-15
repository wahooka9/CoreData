//
//  ViewController.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/12/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "ViewController.h"
#import "CardTableViewCell.h"
#import "CardGenerator.h"

#import "fakeNetworkParser.h"
#import "RepoControllerSingle.h"
#import "Deck+CoreDataProperties.h"
#import "Card+CoreDataProperties.h"

@interface ViewController ()
@property CardGenerator *cg;
@property fakeNetworkParser *parser;
@end

@implementation ViewController
@synthesize cg;
@synthesize parser;

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cell = [UINib nibWithNibName:@"CardTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"Cell"];
    cg = [[CardGenerator alloc] init];
    self.frc = [RepoControllerSingle getCards];
    [self.frc setDelegate:self];
    parser = [[fakeNetworkParser alloc] init];
    parser.delegate = self;
    self.stepperOutlet.minimumValue = 1;
    self.stepperOutlet.maximumValue = 1000;
    self.stepperOutlet.stepValue = 20;
    self.stepperOutlet.value = 100;
    self.deleteRandomCount.text = [NSString stringWithFormat:@"%i",(int)self.stepperOutlet.value];
    [self prefersStatusBarHidden];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) makeCardsSingle {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* data = [cg createDecksAndCardsJson];
        self.methodStart = [NSDate date];
        NSArray *decks = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        //[parser parseData:decks];
        [parser parseDataFaster:decks];
    });
}

-(void)runtimeDate:(NSDate*)finishTime {
    NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:self.methodStart];
    self.timeOutlet.text = [NSString stringWithFormat:@"%.02f",executionTime];
    self.frc = [RepoControllerSingle getCards];
    [self.tableView reloadData];
}

-(void) deleteCards {
    self.methodStart = [NSDate date];
    for (int i = 0; i < self.stepperOutlet.value; i++){
        Card *contextCard = [RepoControllerSingle cardWithID:[[[cg randomCardGenerator] objectForKey:@"cardID"] longValue]];
        [RepoControllerSingle removeObject:contextCard];
    }
    [RepoControllerSingle save];
    [self runtimeDate:[NSDate date]];
}

-(void) deleteAll {
    self.methodStart = [NSDate date];
    NSArray* decks = [RepoControllerSingle getDecks];
    for (Deck *deck in decks){
        [RepoControllerSingle removeObject:deck];
    }
    [RepoControllerSingle save];
    [self runtimeDate:[NSDate date]];
}

-(void) deleteAllBatchDelete {
    self.methodStart = [NSDate date];
    [RepoControllerSingle batchDelete];
    [self runtimeDate:[NSDate date]];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.totalCountOutlet.text = [NSString stringWithFormat:@"%i",(int)self.frc.sections[section].numberOfObjects];
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

- (IBAction)deleteAction:(id)sender {
    [self deleteAll];
}

- (IBAction)createAction:(id)sender {
    [self makeCardsSingle];
}

- (IBAction)stepperAction:(id)sender {
    self.deleteRandomCount.text = [NSString stringWithFormat:@"%i",(int)self.stepperOutlet.value];
}

- (IBAction)deleteRandom:(id)sender {
    [self deleteCards];
}

@end

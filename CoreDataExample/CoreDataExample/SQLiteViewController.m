//
//  SQLiteViewController.m
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/26/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import "SQLiteViewController.h"
#import "CardGenerator.h"
#import "CardTableViewCell.h"
#import "CardSQL.h"
#import "DeckSQL.h"
#import "Database.h"
#import "FakeFetchController.h"

@interface SQLiteViewController ()
@property CardGenerator *cg;
@end

@implementation SQLiteViewController
@synthesize cg;
- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cell = [UINib nibWithNibName:@"CardTableViewCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"Cell"];
    cg = [[CardGenerator alloc] init];
    //self.data = [[NSArray alloc] init];
    [self prefersStatusBarHidden];
    self.ffc = [[FakeFetchController alloc] init];
    self.createStepperOutlet.value = 0;
    self.createStepperOutlet.maximumValue = 50;
    self.createStepperOutlet.minimumValue = 0;
    self.createStepperOutlet.stepValue = 10;
    
    self.deleteStepperOutlet.value = 100;
    self.deleteStepperOutlet.minimumValue = 0;
    self.deleteStepperOutlet.maximumValue = 1000;
    self.deleteStepperOutlet.stepValue = 20;
    
}

-(void)viewDidAppear:(BOOL)animated {
    //self.data = [[Database sharedInstance] scrollUp:1 type:1 number:1];
    [self.tableView reloadData];
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
        
        for (NSDictionary *deck in decks){
                int deckValueID = [[deck objectForKey:@"deckID"] intValue];
                int deckValueName = [[deck objectForKey:@"deckName"] intValue];
                
                DeckSQL *sqlDeck = [[DeckSQL alloc] init];
                [sqlDeck setDeckID:deckValueID];
                [sqlDeck setName:deckValueName];
                
                NSArray *cards = [deck objectForKey:@"cards"];
                    for (NSDictionary *card in cards){
                            long cardID = [[card objectForKey:@"cardID"] longValue];
                            int cardType = [[card objectForKey:@"cardType"]  intValue];
                            int cardNumber = [[card objectForKey:@"cardNumber"]  intValue];
                            int deckID = [[card objectForKey:@"deckID"] intValue];
                            
                            CardSQL *sqlCard = [[CardSQL alloc] init];
                            [sqlCard setDeck_id:deckID];
                            [sqlCard setCardID:cardID];
                            [sqlCard setType:cardType];
                            [sqlCard setNumber:cardNumber];
                            [[Database sharedInstance] saveCard:sqlCard];
                        }
            [[Database sharedInstance] saveDeck:sqlDeck];
        } 
    });
}

-(void) makeCardsSingleBatch {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* data = [cg createDecksAndCardsJson];
        NSArray *decks = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        self.methodStart = [NSDate date];
        
        [[Database sharedInstance] startBulkSave];
        [[Database sharedInstance] saveDecks:decks];
        [[Database sharedInstance] endBulkSave];
        [[Database sharedInstance] closeDataBase];
        
        [[Database sharedInstance] startBulkSave];
        for (NSDictionary *deck in decks){
            NSArray *cards = [deck objectForKey:@"cards"];
            [[Database sharedInstance] saveCards:cards];
        }
        [[Database sharedInstance] endBulkSave];
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.countOutlet.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.data count]];
    return [[Database sharedInstance] getCardCount];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
     CardSQL *card = [self.ffc getCardForIndexPath:indexPath];//[self.data objectAtIndex:indexPath.row];
    cell.cardNumber.text = [NSString stringWithFormat:@"%i",[card number]];
    cell.deckNumber.text = [NSString stringWithFormat:@"%ld",[card deck_id]];
    cell.typeNumber.text = [NSString stringWithFormat:@"%i",[card type]];
    return cell;
}

-(void)runningFinished:(NSDate *)finshed {
    NSTimeInterval executionTime = [finshed timeIntervalSinceDate:self.methodStart];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeOutlet.text = [NSString stringWithFormat:@"%.02f",executionTime];
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
    
}

- (IBAction)deleteAll:(id)sender {
    self.methodStart = [NSDate date];
    self.data = [[Database sharedInstance] getCardList];
    [self.tableView reloadData];
}

- (IBAction)createBatches:(id)sender {
    //[self makeCardsSingle];
    [self makeCardsSingleBatch];
}

@end

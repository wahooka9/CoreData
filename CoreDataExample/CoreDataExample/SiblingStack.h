//
//  SiblingStack.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/25/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SiblingStack : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *saveContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+ (SiblingStack*)sharedInstance;
- (void)save :(NSManagedObjectContext*)moc;
- (NSURL *)applicationDocumentsDirectory;
-(void)setupNotification;

@end

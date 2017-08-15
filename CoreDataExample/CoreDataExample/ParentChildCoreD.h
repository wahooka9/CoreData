//
//  ParentChildCoreD.h
//  CoreDataExample
//
//  Created by Andrew Riznyk on 7/21/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ParentChildCoreD : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+ (ParentChildCoreD*)sharedInstance;
- (void)saveContext :(NSManagedObjectContext*)moc;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)writeManagedObjectContext;

@end

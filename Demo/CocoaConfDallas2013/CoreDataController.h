//
//  CoreDataController.h
//  MeetupContacts
//
//  Created by Kevin Y. Kim on 11/15/12.
//  Copyright (c) 2012 kykim, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) NSPersistentStore *iCloudStore;
@property (nonatomic, readonly) NSPersistentStore *fallbackStore;

@property (nonatomic, readonly) NSURL *ubiquityURL;
@property (nonatomic, readonly) id currentUbiquityToken;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)mergeChangesFromUbiquitousContent:(NSNotification *)notification;

@end

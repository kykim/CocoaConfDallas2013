//
//  CoreDataController.m
//  MeetupContacts
//
//  Created by Kevin Y. Kim on 11/15/12.
//  Copyright (c) 2012 kykim, inc. All rights reserved.
//

#import "CoreDataController.h"

@implementation CoreDataController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init
{
    self = [super init];
    if (self) {
        _ubiquityURL = nil;
        _currentUbiquityToken = nil;
    
//        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
//        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
        _currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
        if (_currentUbiquityToken) {
            NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject:_currentUbiquityToken];
            [[NSUserDefaults standardUserDefaults] setObject: newTokenData forKey: @"com.kykim.CocoaConfDallas2013.UbiquityIdentityToken"];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"com.kykim.CocoaConfDallas2013.UbiquityIdentityToken"];
        }
        
        _ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];

        //subscribe to the account change notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(iCloudAccountChanged:)
                                                     name:NSUbiquityIdentityDidChangeNotification
                                                    object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeChangesFromUbiquitousContent:)
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                   object:coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CocoaConfDallas2013" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSString *dataFileName = @"CocoaConfDallas2013.sqlite";
    __block NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPersistentStore *newStore = nil;
        NSError *error = nil;
        
        NSString *dataDirName = @"Data.nosync";
        NSString *logsDirName = @"TransactionLogs";
        
        if (_currentUbiquityToken && _ubiquityURL) {
            NSString *dataDirPath = [[_ubiquityURL path] stringByAppendingPathComponent:dataDirName];
            NSURL *logsDirURL = [NSURL fileURLWithPath:[[_ubiquityURL path] stringByAppendingPathComponent:logsDirName]];
            if([[NSFileManager defaultManager] fileExistsAtPath:dataDirPath] == NO) {
                NSError *fileSystemError;
                [[NSFileManager defaultManager] createDirectoryAtPath:dataDirPath
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:&fileSystemError];
                if(fileSystemError != nil) {
                    NSLog(@"Error creating database directory %@", fileSystemError);
                }
            }
            
            NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                       NSInferMappingModelAutomaticallyOption       : @YES,
                                       NSPersistentStoreUbiquitousContentNameKey    : [_ubiquityURL lastPathComponent],
                                       NSPersistentStoreUbiquitousContentURLKey     : logsDirURL };
            
            [psc lock];
            NSURL *dataFileURL = [NSURL fileURLWithPath:[dataDirPath stringByAppendingPathComponent:dataFileName]];
            newStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                                   URL:dataFileURL
                                               options:options
                                                 error:&error];
            [psc unlock];
        }
        else {
            NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
            NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                       NSInferMappingModelAutomaticallyOption       : @YES };
            [psc lock];
            newStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                                   URL:storeURL
                                               options:options
                                                 error:&error];
            [psc unlock];
        }

        if (!newStore) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"refreshUI"
                                                                            object:self
                                                                          userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    });
    
    return _persistentStoreCoordinator;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:100];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
//    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Handle Changes from iCloud to Ubiquitous Container

- (void)mergeChangesFromUbiquitousContent:(NSNotification *)notification
{
    NSManagedObjectContext* moc = [self managedObjectContext];
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:notification];
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"refreshUI"
                                                                            object:self
                                                                          userInfo:[notification userInfo]];
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

@end

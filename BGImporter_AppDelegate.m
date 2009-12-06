//
//  BGImporter_AppDelegate.m
//  BGImporter
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright Flying Jalapeño Software 2009 . All rights reserved.
//

#import "BGImporter_AppDelegate.h"
#import "CoreDataFunctions.h"
#import "BGImporterCoreDataFunctions.h"
#import "NSManagedObjectContext+Extensions.h"
#import "NSString+extensions.h"
#import "Company.h"
#import "NSSet+blocks.h"
#import "Brand.h"
#import "Category.h"

@implementation BGImporter_AppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(NSNotification *)notification{
    
    [self removeOldDatabase];
    
    NSError* saveError = importUsingCSV(self.managedObjectContext);   
    NSLog(@"%@",[saveError description]);
    
    [self moveDatabaseToProjectFolder];
    
    int numberOfCompanies = [self.managedObjectContext numberOfEntitiesWithName:@"Company"];
    NSLog(@"Number of Companies: %@", [NSString stringWithInt:numberOfCompanies]);
    
    
    NSArray* cats = allCategories(self.managedObjectContext);
        
    NSLog(@"Number of Categories: %@", [NSString stringWithInt:[self.managedObjectContext numberOfEntitiesWithName:@"Category"]]);
    
    //NSLog(@"%@",[companies description]);
    
    for(Category* eachCat in cats){
        
        NSLog(@"%@", @"____________________");
        NSLog(@"%@", eachCat.name);
        NSLog(@"%@", eachCat.nameDisplayFriendly);
        NSLog(@"%@", @"____________________");
        
        /*
        [eachCompany.brands each:^(id eachBrand){
            
            NSLog(@"%@", [(Brand*)eachBrand name]);
            NSLog(@"%@", [(Brand*)eachBrand namefirstLetter]);

        }];
        */
        
    }
    
    //Company* ofInterest = [[companies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == 402"]] objectAtIndex:0];
    
    //NSLog(@"%@", ofInterest.name);

    //Company* ofInterest = [[self.managedObjectContext entitiesWithName:@"Company" where:@"name" like:@"Wells"] objectAtIndex:0];
    //NSLog(@"%@", ofInterest.name);
    
    NSArray* results = [self.managedObjectContext entitiesWithName:@"Company" where:@"name" like:@"Wells Fargo"];
    if([results count]>0){
        Company* ofInterest = [results objectAtIndex:0];
        NSLog(@"%@", ofInterest.name);
    }
    
     
    
    
}

- (void)removeOldDatabase{
    
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSURL *url = [NSURL fileURLWithPath:[applicationSupportDirectory stringByAppendingPathComponent: @"storedata.sqlite"]];
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];

}


- (void)moveDatabaseToProjectFolder{
    
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSURL *url = [NSURL fileURLWithPath:[applicationSupportDirectory stringByAppendingPathComponent: @"storedata.sqlite"]];
    NSURL *dest = [NSURL fileURLWithPath:@"/Users/coreyfloyd/Development/ProductionProjects/HRC/BuyingGuide/storedata.sqlite"];
   
    [[NSFileManager defaultManager] removeItemAtURL:dest error:nil];
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:dest error:nil];
    
}


/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "BGImporter" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"BGImporter"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata.sqlite"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}


@end

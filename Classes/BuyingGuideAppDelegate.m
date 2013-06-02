//
//  BuyingGuideAppDelegate.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/15/09.
//  Copyright Flying Jalapeño Software 2009. All rights reserved.
//

#import "BuyingGuideAppDelegate.h"
#import "MainViewController.h"
#import "CompaniesTableViewController.h"
#import "CategoriesTableViewController.h"
#import "Flurry.h"
#import "RootViewController.h"
#import "JSON.h"
#import "NSManagedObjectContext+Extensions.h"
#import "BGBrand.h"
#import "BGCompany.h"
#import "BGScorecard.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UIBarButtonItem+extensions.h"
#import <Crashlytics/Crashlytics.h>

#define UPDATE_INTERVAL 86400 //seconds == 1 days

//#define LOAD_FROM_FILE
//#define FORCE_COPY_BUNDLE_LIBRARY
//#define FORCE_FULL_DOWNLOAD
//#define DISABLE_UPDATE
//#define DEV_MODE_APNS

static NSString * const kLastUpdateDateKey = @"LastUpdateDateKey";
static NSString* previouslyLaunchedKey = @"HRCFirstLaunch";

@interface BuyingGuideAppDelegate ()

@property (nonatomic, assign) BOOL isCancelled;

- (void)dataUpdateDidFinish;
- (void)updateDataWFromLocalJSON;

@end

@implementation BuyingGuideAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize splashView;
@synthesize hud;
@synthesize start;

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Override point for customization after app launch    
	   
    self.isCancelled = NO;
    
    [Flurry startSession:@"S7CW8QM9RR32D7Z4R9FP"];
    
#ifdef DEV_MODE_APNS
    [Parse setApplicationId:@"ic4i76xfP63YNoPiuKuyQ8Xn5d3vaSsuBGiJTcFD"
                  clientKey:@"UYIawfHhlLdL19jVqgduhTtihblA34G1GJQaGTV9"];
#else
    [Parse setApplicationId:@"rlaChslPPFKJRneSpeeb8Ixbp49IknB6No9bJWAZ"
                  clientKey:@"nmCd0eeTe9CybiY4029NQoRpttBoBARF3ktKijAt"];
#endif
    
    [Crashlytics startWithAPIKey:@"354c5c1417dcc19fd4a99b58c69a0457e22475d1"];

    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    BOOL forceCopyBundleLibary = NO;

#ifdef FORCE_COPY_BUNDLE_LIBRARY
    
    forceCopyBundleLibary = YES;
    
#endif

#ifdef FORCE_FULL_DOWNLOAD

    NSString* currentAppDB = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"];
    [[NSFileManager defaultManager] removeItemAtPath:currentAppDB error:nil];

#else
    
    [self loadDataBaseCopyFromBundleForce:forceCopyBundleLibary];

#endif
    
    NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
    NSString* newBundleID = [info objectForKey:(NSString*)kCFBundleVersionKey];
    [[NSUserDefaults standardUserDefaults] setObject:newBundleID forKey:(NSString*)kCFBundleVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    MainViewController *rootViewController = [[MainViewController alloc] init];
	rootViewController.managedObjectContext = self.managedObjectContext;
    
    [window makeKeyAndVisible];

    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = nc;
    self.navigationController = nc;
    [nc release];
    
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken]; // Send parse the device token

    // Subscribe this user to the broadcast channel, ""
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            DebugLog(@"Successfully subscribed to the broadcast channel.");
        } else {
            DebugLog(@"Failed to subscribe to the broadcast channel.");
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DebugLog(@"Failed to register for APNS: %@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

#pragma mark

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#ifdef LOAD_FROM_FILE
    [self updateDataWFromLocalJSON];
#endif

    NSDate *lastUpdateDate = nil;

#ifdef FORCE_FULL_DOWNLOAD
    lastUpdateDate = nil;
#else
    lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdateDateKey];
#endif
    
    if(!lastUpdateDate || [[NSDate date] timeIntervalSinceDate:lastUpdateDate] > UPDATE_INTERVAL){
        
#ifdef DISABLE_UPDATE
        DebugLog(@"Updates Disabled");
        [self dataUpdateDidFinish];
#else
       [self updateDataWithLastUpdateDate:lastUpdateDate];
#endif

    } else {
        [self dataUpdateDidFinish];
    }
}

- (void)removeSplashScreen
{

    [self.hud hide:NO];
    [self.hud removeFromSuperview];
    self.hud = nil;

    [UIView animateWithDuration:0.75 animations:^{
        
        self.splashView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [self.splashView removeFromSuperview];
        self.splashView = nil;
        
    }];
    
}

- (void)addSplashScreen
{
	UIView *localSplashView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.splashView = localSplashView;
	[localSplashView release];
    
    UIImageView * imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    imageView.frame = self.splashView.frame;
    [self.splashView addSubview:imageView];
    
    UIToolbar * bar = [[UIToolbar alloc] initWithFrame:(CGRect){0, 0, self.splashView.frame.size.width, 44}];
    [bar setItems:[NSArray arrayWithObjects:
                   [UIBarButtonItem flexibleSpaceItem],
                   [UIBarButtonItem systemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)],
                   nil]];
    [self.splashView addSubview:bar];
    [bar release];

    self.splashView.alpha = 0.0;
    [window addSubview:self.splashView];
    
    [UIView animateWithDuration:0.75 animations:^{

        self.splashView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        [self.hud hide:NO];
        [self.hud removeFromSuperview];
        self.hud = [[MBProgressHUD alloc] initWithView:imageView];
        [self.splashView addSubview:self.hud];
        
        self.hud.labelText = @"Updating. Please wait…";
        [self.hud show:YES];
        
    }];
    
    
   
    
}

- (void)cancel:(id)sender
{
    self.isCancelled = YES;
}

- (void) dataUpdateDidFinish {
        
    NSTimeInterval s = [[NSDate date] timeIntervalSinceDate:self.start];
    NSLog(@"Time to import: %f", s);
    
    // Upon finish, deal with cancellation
    if (self.isCancelled) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathForAppDBCopy]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self pathForAppDB] error:nil];
            NSError * copyError = nil;
            [[NSFileManager defaultManager] copyItemAtPath:[self pathForAppDBCopy]
                                                    toPath:[self pathForAppDB]
                                                     error:&copyError];
            if (copyError) {
                NSLog(@"Error replacing cancelled DB with copy");
            }
        }
        self.isCancelled = NO;
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self removeSplashScreen];
        
        BOOL previouslyLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:previouslyLaunchedKey];
        
        if(!previouslyLaunched){

            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [(MainViewController*)[[(UINavigationController*)self.window.rootViewController viewControllers] objectAtIndex:0] showKey];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:previouslyLaunchedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];

            });
        }
    });
    

}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}

#pragma mark - Update Database

- (void)updateLoadedData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // Make a copy of the db in case update is cancelled midway
        NSError * copyError = nil;
        [[NSFileManager defaultManager] copyItemAtPath:[self pathForAppDB]
                                                toPath:[self pathForAppDBCopy]
                                                 error:&copyError];
        if (copyError) {
            NSLog(@"Error making copy of DB");
        }
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *updateDict = [parser objectWithData:_updateData];
        [parser release];
        [_updateData release];
        _updateData = nil;
        
        NSArray *brands = [[updateDict valueForKeyPath:@"brands"] valueForKey:@"row"];
        NSArray *categories = [[updateDict valueForKeyPath:@"categories"] valueForKey:@"row"];
        NSArray *organizations = [[updateDict valueForKeyPath:@"organizations"] valueForKey:@"row"];
        NSArray *scorecards = [[updateDict valueForKeyPath:@"scorecards"] valueForKey:@"row"];
        NSArray *removed = [[updateDict valueForKeyPath:@"removed"] valueForKey:@"row"];

//        DebugLog(@"Brand example: %@", brands[0]);
//        DebugLog(@"Categories example: %@", categories[0]);
//        DebugLog(@"Orgs example: %@", organizations[0]);
//        DebugLog(@"Scorecards example: %@", scorecards[0]);

        NSString *JSONSyncPath = [[NSBundle mainBundle] pathForResource:@"JSONSync" ofType:@"plist"];
        NSDictionary *JSONSyncDict = [NSDictionary dictionaryWithContentsOfFile:JSONSyncPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([organizations count] > 0 || [brands count] > 0){
                [self addSplashScreen];
            }
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                DebugLog(@"-----------------");
                DebugLog(@"Category json: %i", [categories count]);
                DebugLog(@"Category coredata before update: %i", [self countForEntityName:@"BGCategory"]);
                if (!self.isCancelled) {
                    [self syncEntity:@"BGCategory" withJSONObjects:categories syncDictionaries:[JSONSyncDict objectForKey:@"BGCategory"]];
                }
                if (!self.isCancelled) {
                    [self saveData];
                }
                DebugLog(@"Category coredata after update: %i", [self countForEntityName:@"BGCategory"]);
                DebugLog(@"-----------------");
                
                
                DebugLog(@"Organizations json: %i", [organizations count]);
                DebugLog(@"Organizations coredata before update: %i", [self countForEntityName:@"BGCompany"]);
                if (!self.isCancelled) {
                    [self syncEntity:@"BGCompany" withJSONObjects:organizations syncDictionaries:[JSONSyncDict objectForKey:@"BGCompany"]];
                }
                if (!self.isCancelled) {
                    [self saveData];
                }
                DebugLog(@"Organizations coredata after update: %i", [self countForEntityName:@"BGCompany"]);
                DebugLog(@"-----------------");

                
                DebugLog(@"Brand json: %i", [brands count]);
                DebugLog(@"Brand coredata before update: %i", [self countForEntityName:@"BGBrand"]);
                if (!self.isCancelled) {
                    [self syncEntity:@"BGBrand" withJSONObjects:brands syncDictionaries:[JSONSyncDict objectForKey:@"BGBrand"]];
                }
                if (!self.isCancelled) {
                    [self saveData];
                }
                DebugLog(@"Brand coredata after update: %i", [self countForEntityName:@"BGBrand"]);
                DebugLog(@"-----------------");

                
                if([organizations count] > 0 || [brands count] > 0){
                    DebugLog(@"Scorecard json: %i", [scorecards count]);
                    DebugLog(@"Scorecard coredata before update: %i", [self countForEntityName:@"BGScorecard"]);
                    if (!self.isCancelled) {
                        [self syncEntity:@"BGScorecard" withJSONObjects:scorecards syncDictionaries:[JSONSyncDict objectForKey:@"BGScorecard"]];
                    }
                    if (!self.isCancelled) {
                        [self saveData];
                    }
                    DebugLog(@"Scorecard coredata after update: %i", [self countForEntityName:@"BGScorecard"]);
                    DebugLog(@"-----------------");
                }
                
                if (!self.isCancelled) {
                    [self markOrganizationsAsDeletedWithJSON:removed]; // do we need this?
                }
                if (!self.isCancelled) {
                    [self saveData];

                    NSDate *lastUpdateDate = [NSDate date];
                    [[NSUserDefaults standardUserDefaults] setObject:lastUpdateDate forKey:kLastUpdateDateKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                [self.navigationController popViewControllerAnimated:NO];
                MainViewController *rootViewController = (MainViewController *)[[navigationController viewControllers] objectAtIndex:0];
                rootViewController.managedObjectContext = self.managedObjectContext;
                rootViewController.categoryView.managedObjectContext = self.managedObjectContext;
                rootViewController.companyView.managedObjectContext = self.managedObjectContext;
                [rootViewController.categoryView fetchAndReload];
                [rootViewController.companyView fetchAndReload];
                [rootViewController.modeSwitch setSelectedSegmentIndex:0];
                [rootViewController loadCategories];
                
                [self dataUpdateDidFinish];
            });
        });
    });
}

- (int)countForEntityName:(NSString *)name// coreDataKey:(NSString *)cdKey jsonKey:(NSString *)jsonKey
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest * f = [[NSFetchRequest alloc] init];
    [f setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:moc]];

    NSError* error = nil;
    NSMutableArray * entities = [[moc executeFetchRequest:f error:&error] mutableCopy];
    if (entities == nil){
        NSLog(@"Error: %@", [error description]);
    }
    [f release];
    
    return [entities count];
}

- (BOOL)syncEntity:(NSString *)entityName
   withJSONObjects:(NSArray *)JSONObjects
  syncDictionaries:(NSArray *)syncDictionaries
{	
    if ( !syncDictionaries || ![syncDictionaries count] || !entityName || !JSONObjects || self.isCancelled) {
		return NO;
    }
	
	NSDictionary *primaryKeyDict = [syncDictionaries objectAtIndex:0];
	NSString *coreDataKey = [primaryKeyDict valueForKey:@"CoreDataKey"];
	NSString *JSONKey = [primaryKeyDict valueForKey:@"JSONKey"];
		
	NSManagedObjectContext *moc = [self managedObjectContext];
    [moc setMergePolicy:NSOverwriteMergePolicy];
    
	NSMutableSet *uniqueKeySet = [NSMutableSet setWithArray:[JSONObjects valueForKey:JSONKey]];
	[uniqueKeySet removeObject:[NSNull null]];
	
//    NSLog(@"unique keys: %i", [uniqueKeySet count]);
    
    NSFetchRequest* f = [[NSFetchRequest alloc] init];
    [f setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [f setPredicate:[NSPredicate predicateWithFormat:@"%K IN %@", coreDataKey , uniqueKeySet]];
    if ([entityName isEqualToString:@"BGScorecard"])
        [f setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES]]];
    else
        [f setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES]]];
    
    NSError* error = nil;
    NSMutableArray *entitiesToUpdate = [[moc executeFetchRequest:f error:&error] mutableCopy];
    if (entitiesToUpdate == nil){
        NSLog(@"error: %@", [error description]);
    }
    [f release];
    
	//NSMutableArray *entitiesToUpdate = [[moc entitiesWithName:entityName whereKey:coreDataKey isIn:uniqueKeySet] mutableCopy];
	NSMutableArray * entityUniqueIDs = [[entitiesToUpdate valueForKey:coreDataKey] mutableCopy];
    
//    NSLog(@"entityUniqueIDs: %i", [entityUniqueIDs count]);

    if([entityName isEqualToString:@"BGCompany"]){
        for (BGCompany * each in entitiesToUpdate) {
            
//            for(BGBrand * eachBrand in each.brands) {
//                [moc deleteObject:eachBrand];
//            }
            
            for(BGScorecard * eachScorecard in each.scorecards) {
                [moc deleteObject:eachScorecard];
            }
        }
        
        [self saveData];
    }
    
    NSDictionary *secondaryKeyDict = [syncDictionaries objectAtIndex:1];
    NSString *secondaryCoreDataKey = [secondaryKeyDict valueForKey:@"CoreDataKey"];
    NSString *secondaryJSONKey = [secondaryKeyDict valueForKey:@"JSONKey"];
            
    NSMutableSet *secondaryKeySet = [NSMutableSet setWithArray:[JSONObjects valueForKey:secondaryJSONKey]];
    [secondaryKeySet removeObject:[NSNull null]];
    
    NSMutableArray *secondaryEntitiesToUpdate = [[moc entitiesWithName:entityName whereKey:secondaryCoreDataKey isIn:secondaryKeySet] mutableCopy];
    NSMutableArray *entitySecondaryIDs = [[secondaryEntitiesToUpdate valueForKey:secondaryCoreDataKey] mutableCopy];
    
//    NSLog(@"entitySecondaryIDs: %i", [entitySecondaryIDs count]);

    int totalDeletions = 0;
	for ( id JSONObject in JSONObjects ) { // For each object returned from the API...
	
        if (self.isCancelled) {
            return NO;
        }
        
        NSString *IDString = [JSONObject valueForKey:JSONKey]; // uniqueId
        NSString* secondaryIDString = [JSONObject valueForKey:secondaryJSONKey]; // brand name
        id secondaryID = secondaryIDString;

		id ID = nil; // properly typed uniqueId
        if ([[primaryKeyDict objectForKey:@"kind"] isEqualToString:@"Integer"]) {
            ID = [NSNumber numberWithInt:[IDString intValue]];
        } else {
            ID = IDString;
        }
        
        // Attempt to get the existing entity
		id entity = nil;
		NSInteger index = [entityUniqueIDs indexOfObject:ID];
		if ( index != NSNotFound && ![entityName isEqualToString:@"BGScorecard"]) { // GET EXG ENTITY BASED ON UNIQUEID
			entity = [entitiesToUpdate objectAtIndex:index];

		} else {
            index = [entitySecondaryIDs indexOfObject:secondaryID];
            if ( index != NSNotFound && ![entityName isEqualToString:@"BGScorecard"]){ // ELSE GET EXG ENTITY BASED ON BRAND NAME
                entity = [secondaryEntitiesToUpdate objectAtIndex:index];
                [entitiesToUpdate addObject:entity];
                [entityUniqueIDs addObject:ID];
            }
        }

        // Delete existing object if necessary (IsCurrentInd == false), and continue to next json object
        if([entityName isEqualToString:@"BGBrand"]){
            if ([JSONObject valueForKey:@"IsCurrentInd"]) {
                BOOL isActive = [[JSONObject valueForKey:@"IsCurrentInd"] boolValue];
                if (!isActive) {
                    if (entity) {
                        
//                        NSLog(@"Deleted %@: %@", entityName, ID);
                        
                        [entitiesToUpdate removeObject:entity];
                        [entityUniqueIDs removeObject:ID];
                        [secondaryEntitiesToUpdate removeObject:entity];
                        [entitySecondaryIDs removeObject:secondaryID];
                        
                        [moc deleteObject:entity];
                        [self saveData];
                    }
                    totalDeletions++;
                    continue;
                }
            }
        }
        
//        NSLog(@"Updated: %@", ID);

        // Otherwise create a new entity
        if (!entity) {
            entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc]; // ELSE CREATE NEW ENTITY
            if ( ID && entity ) {
                [entitiesToUpdate addObject:entity];
                [entityUniqueIDs addObject:ID];
                [secondaryEntitiesToUpdate addObject:entity];
                [entitySecondaryIDs addObject:secondaryID];
            }
        }
        
        if (!entity) {
//            NSLog(@"no entity!");
        }
                    
        // If not deleted, update entity with the new JSON values
        for ( NSDictionary *keyDict in syncDictionaries ) { // For each property on each object returned from the API...
            NSString *coreDataKey = [keyDict objectForKey:@"CoreDataKey"];
            NSString *JSONKey = [keyDict objectForKey:@"JSONKey"];
            
            if ([JSONKey isEqualToString:@"IsCurrentInd"]) { // CoreData entity does not store this property (no need to)
                continue;
            }
            
            id value = nil;
            id JSONValue = [JSONObject valueForKey:JSONKey];
            
            if ([[keyDict valueForKey:@"kind"] isEqualToString:@"Integer"]) {
                value = [NSNumber numberWithInt:[JSONValue intValue]];
            } else {
                value = JSONValue;
            }
            
            NSString *transformer = [keyDict objectForKey:@"transformer"];
            if ( transformer ) {
                SEL selector = NSSelectorFromString(transformer);
                if ( [value respondsToSelector:selector] )
                    value = [value performSelector:selector];
            }
            
            if ( !value ) {
                continue;
            }
                 
            NSString *relationshipEntity = [keyDict objectForKey:@"CoreDataRelationshipEntity"];
            if ( relationshipEntity ) {
                NSString *relationshipKey = [keyDict objectForKey:@"CoreDataRelationshipKey"];
                NSString *relationshipSelectorString = [keyDict objectForKey:@"CoreDataRelationshipMethod"];
                SEL relationshipSelector = NSSelectorFromString(relationshipSelectorString);
                if ( [entity respondsToSelector:relationshipSelector] ) {
                    id relatedObject = [moc entityWithName:relationshipEntity whereKey:relationshipKey equalToObject:value];
                    if (relatedObject) {
                        [entity performSelector:relationshipSelector withObject:relatedObject];
                    }
                }
            } else {
                [entity setValue:value forKey:coreDataKey];
            }
        }
    }
    DebugLog(@"Total deletions: %i", totalDeletions);

	[entitiesToUpdate release];
	[entityUniqueIDs release];
    [secondaryEntitiesToUpdate release];
    [entitySecondaryIDs release];
	
	return YES;
}

// DO WE NEED THIS ANYMORE?
- (void)markOrganizationsAsDeletedWithJSON:(NSArray*)JSONObjects{
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSMutableSet *uniqueKeySet = [NSMutableSet setWithArray:[JSONObjects valueForKey:@"OrgID"]];
	[uniqueKeySet removeObject:[NSNull null]];
    
    NSFetchRequest* f = [[NSFetchRequest alloc] init];
    [f setEntity:[NSEntityDescription entityForName:@"BGCompany" inManagedObjectContext:moc]];
    [f setResultType:NSDictionaryResultType];
    [f setPropertiesToFetch:[NSArray arrayWithObject:@"remoteID"]];
    
    NSError* error = nil;
    NSArray *allEentities = [moc executeFetchRequest:f error:&error];
    NSMutableArray* allIDs = [[allEentities valueForKey:@"allObjects"] mutableCopy];
    [allIDs removeObject:[NSNull null]];
    
	NSMutableArray *entitiesToUpdate = [[moc entitiesWithName:@"BGCompany" whereKey:@"remoteID" isIn:uniqueKeySet] mutableCopy];
    
    [entitiesToUpdate enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BGCompany* c = obj;
        c.includeInIndex = [NSNumber numberWithBool:NO];
        
        [c.brands enumerateObjectsUsingBlock:^(id bobj, BOOL *stop) {
            BGBrand* b = bobj;
            b.includeInIndex = [NSNumber numberWithBool:NO];
        }];
    }];
}

- (void)saveData
{
	NSError *error = nil;
	[[self managedObjectContext] save:&error];
	if ( error ) {
		FJSLog(@"%@", error);
		error = nil;
	}
}

- (void)updateLoadedDataInBackground { 
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self updateLoadedData];
	[pool drain];
}

- (void)updateDataWFromLocalJSON {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"TestJSON" ofType:@"txt"];	
    NSMutableData* d = [[NSMutableData alloc] initWithContentsOfFile:path];
    _updateData = d;
    
    [self performSelectorOnMainThread:@selector(updateLoadedData) withObject:nil waitUntilDone:NO];
}

- (void)updateDataWithLastUpdateDate:(NSDate *)lastUpdate
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.start = [NSDate date]; 
    
    
	NSString *URLString = @"http://fj.hrc.org/2013/app_connect.php?content-type=json&key=41e97990456ae2eb1b5bacb69e86685c";
	if ( lastUpdate ) {
		NSDateFormatter *updateURLDateFormatter = [[NSDateFormatter alloc] init];
		[updateURLDateFormatter setDateFormat:@"ddMMMYYYY"];
		URLString = [NSString stringWithFormat:@"%@&date=%@", URLString, [updateURLDateFormatter stringFromDate:lastUpdate]];
		[updateURLDateFormatter release];
	}

	NSURL *url = [NSURL URLWithString:URLString];
	
	_updateData = [[NSMutableData alloc] init];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	_updateConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	[request release];
}

- (void)loadDataBaseCopyFromBundleForce:(BOOL)flag{

    //remove old DB
    NSString* oldDatabase = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"storedata.sqlite"];
    [[NSFileManager defaultManager] removeItemAtPath:oldDatabase error:nil];
    
    
    NSString* bundleDB = [[NSBundle mainBundle] pathForResource:@"storedata" ofType:@"sqlite"];
	NSString* currentAppDB = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"];
	
    NSDictionary* bundleAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:bundleDB error:nil];
	NSDictionary* currentAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:currentAppDB error:nil];
    NSDate* bundleCreationDate = [bundleAttributes objectForKey:NSFileCreationDate];
    NSDate* currentCreationDate = [currentAttributes objectForKey:NSFileCreationDate];
    

	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
	
	NSString* newBundleID = [info objectForKey:(NSString*)kCFBundleVersionKey];
    NSString* currentBundleID = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString*)kCFBundleVersionKey];

    BOOL shouldCopyDb = NO;
    
    if( flag ){//force the issue
        
        shouldCopyDb = YES;
        
    }else if(currentBundleID == nil){ //no bundleID, app never launched?
        
        shouldCopyDb = YES;
        
    }else if(currentAttributes == nil && bundleDB){ //no current DB
        
        shouldCopyDb = YES;
        
        
    }else if(currentBundleID != nil && ![newBundleID isEqualToString:currentBundleID] && bundleDB){ //if this is a new version of the app
        
        shouldCopyDb = YES;
        
    }else if([bundleCreationDate compare:currentCreationDate] == NSOrderedDescending && bundleDB ){  //If the creation date of the bundle db is newer
        
        shouldCopyDb = YES;
    }
    
    if (shouldCopyDb) {
        
        // copy db
		[[NSFileManager defaultManager] removeItemAtPath:currentAppDB error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:bundleDB 
                                                toPath:currentAppDB 
                                                 error:nil];
        
        // set date that bundled db pulled data
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setCalendar:[NSCalendar currentCalendar]];
        [components setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
        [components setYear:2013];
        [components setMonth:05];
        [components setDay:31];
        [components setHour:16];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *lastUpdateDate = [components date];
        
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateDate forKey:kLastUpdateDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [components release];
        
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    /*
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
    */
    
    NSString *momdPath = [[NSBundle mainBundle]
                          pathForResource:@"BuyingGuide" ofType:@"momd"];
    
    NSURL *momdURL = [NSURL fileURLWithPath:momdPath];
    
    managedObjectModel = [[NSManagedObjectModel alloc]
                          initWithContentsOfURL:momdURL];
    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"storedata.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        
        //looks like we have an old db version, lets just blow it away and grab the static one. no need to migrate, no personal data
        [self loadDataBaseCopyFromBundleForce:YES];
        
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
         
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);       
		}
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)pathForAppDBCopy
{
    return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata_copy.sqlite"];
}

- (NSString *)pathForAppDB
{
    return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"];
}

- (NSString *)pathForBundleDB
{
    return [[NSBundle mainBundle] pathForResource:@"storedata" ofType:@"sqlite"];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    self.splashView = nil;
	
    [hud release];
    hud = nil;
        
    [_updateData release];
	[_updateConnection release];
	
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[navigationController release];
	[window release];
	[super dealloc];
}

						
#pragma mark -
#pragma mark NSURLConnectionDelegate


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	FJSLog(@"Did receive auth challenge: %@", challenge);
}
- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[self dataUpdateDidFinish];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ( [response isKindOfClass:[NSHTTPURLResponse class]] ) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		NSInteger statusCode = [httpResponse statusCode];
		if ( statusCode != 200 )
			NSLog(@"Unable to reach update server: %@", [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_updateData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ( connection == _updateConnection ) {
		[_updateConnection release];
		_updateConnection = nil;
		[self performSelectorOnMainThread:@selector(updateLoadedData) withObject:nil waitUntilDone:NO];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ( connection == _updateConnection ) {
		[_updateConnection release];
		_updateConnection = nil;
	}
	[self dataUpdateDidFinish];
}

@end


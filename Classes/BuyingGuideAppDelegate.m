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
#import "FlurryAPI.h"
#import "RootViewController.h"
#import "JSON.h"
#import "NSManagedObjectContext+Extensions.h"
#import "BGBrand.h"
#import "BGCompany.h"
#import "BGScorecard.h"
#import "MBProgressHUD.h"

#define UPDATE_INTERVAL 86400 //seconds == 1 days

//#define LOAD_FROM_FILE
//#define FORCE_COPY_BUNDLE_LIBRARY
//#define FORCE_FULL_DOWNLOAD



static NSString * const kLastUpdateDateKey = @"LastUpdateDateKey";

@interface BuyingGuideAppDelegate ()

- (void) dataUpdateDidFinish;
- (void)updateDataWFromLocalJSON;

@end

@implementation BuyingGuideAppDelegate

static NSString* kAnimationID = @"SplashAnimation";

@synthesize window;
@synthesize navigationController;
@synthesize splashView;
@synthesize hud;
@synthesize start;



#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Override point for customization after app launch    
	
    [FlurryAPI startSession:@"4bbfd488141c84699824c518b281b86e"];
    
    
    BOOL forceCopyBundleLibary;
    
    forceCopyBundleLibary = NO;
    
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
    

    MainViewController *rootViewController = (MainViewController *)[navigationController topViewController];
	rootViewController.managedObjectContext = self.managedObjectContext;
    [window addSubview:[navigationController view]];

	[window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
        
    
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
        
        [self updateDataWithLastUpdateDate:lastUpdateDate];

    }else{
        
        [self dataUpdateDidFinish];            

    }
    
}

-(void) removeSplashScreen{
	[UIView beginAnimations:kAnimationID context:nil];
	[UIView setAnimationDuration:1.0];
    splashView.alpha = 0;
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];	
}

-(void) addSplashScreen{
	UIImageView *localSplashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
	localSplashView.frame = [[UIScreen mainScreen] applicationFrame];
	self.splashView = localSplashView;
	[window addSubview:splashView];
	[localSplashView release];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
    if([animationID isEqualToString:kAnimationID]){
        
        [self.splashView removeFromSuperview];
        self.splashView = nil;
        
    }
}

- (void) dataUpdateDidFinish {
        
    NSTimeInterval s = [[NSDate date] timeIntervalSinceDate:self.start];
    NSLog(@"Time to import: %f", s);
    
    [self.hud hide:NO];
    [self.hud removeFromSuperview];
    self.hud = nil;
    
	[self performSelector:@selector(removeSplashScreen) withObject:nil afterDelay:0.1];
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


- (BOOL)syncEntity:(NSString *)entityName withJSONObjects:(NSArray *)JSONObjects syncDictionaries:(NSArray *)syncDictionaries {
	if ( !syncDictionaries || ![syncDictionaries count] || !entityName || !JSONObjects )
		goto bail;
	
	NSDictionary *primaryKeyDict = [syncDictionaries objectAtIndex:0];
	
	NSString *coreDataKey = [primaryKeyDict valueForKey:@"CoreDataKey"];
	NSString *JSONKey = [primaryKeyDict valueForKey:@"JSONKey"];
		
	NSManagedObjectContext *moc = [self managedObjectContext];
    [moc setMergePolicy:NSOverwriteMergePolicy];
    
	NSMutableSet *uniqueKeySet = [NSMutableSet setWithArray:[JSONObjects valueForKey:JSONKey]];
	[uniqueKeySet removeObject:[NSNull null]];
	
    NSFetchRequest* f = [[NSFetchRequest alloc] init];
    [f setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [f setPredicate:[NSPredicate predicateWithFormat:@"%K IN %@",coreDataKey , uniqueKeySet]];
    if ([entityName isEqualToString:@"BGScorecard"])
        [f setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES]]];
    else
        [f setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES]]];
    
    NSError* error = nil;
    NSMutableArray *entitiesToUpdate = [[moc executeFetchRequest:f error:&error] mutableCopy];
    
    if(entitiesToUpdate == nil){
        
        NSLog(@"error: %@", [error description]);
    }
    
    [f release];
    
	//NSMutableArray *entitiesToUpdate = [[moc entitiesWithName:entityName whereKey:coreDataKey isIn:uniqueKeySet] mutableCopy];
	NSMutableArray *entityUniqueIDs = [[entitiesToUpdate valueForKey:coreDataKey] mutableCopy];
    
    
    if([entityName isEqualToString:@"BGCompany"]){
        
        //Delete all brands for any updated company
        
        for(BGCompany* each in entitiesToUpdate){
            
            for(BGBrand* eachBrand in each.brands){
                
                [moc deleteObject:eachBrand];
                
            }
            
            for(BGScorecard* eachScorecard in each.scorecards){
                
                [moc deleteObject:eachScorecard];
                
            }
            
        }
        
        [self saveData];

    }
    
    
    //use name just in case
    NSDictionary *secondaryKeyDict = [syncDictionaries objectAtIndex:1];
    NSString *secondaryCoreDataKey = [secondaryKeyDict valueForKey:@"CoreDataKey"];
    NSString *secondaryJSONKey = [secondaryKeyDict valueForKey:@"JSONKey"];
            
    NSMutableSet *secondaryKeySet = [NSMutableSet setWithArray:[JSONObjects valueForKey:secondaryJSONKey]];
    [secondaryKeySet removeObject:[NSNull null]];
    
    /*
    f = [[NSFetchRequest alloc] init];
    [f setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [f setPredicate:[NSPredicate predicateWithFormat:@"%K IN %@",secondaryCoreDataKey , secondaryKeySet]];
    [f setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES]]];
    
    error = nil;
    NSMutableArray *secondaryEntitiesToUpdate = [[moc executeFetchRequest:f error:&error] mutableCopy];
    
    if(secondaryEntitiesToUpdate == nil){
        
        NSLog(@"error: %@", [error description]);
    }
    
    [f release];
    */
    
    NSMutableArray *secondaryEntitiesToUpdate = [[moc entitiesWithName:entityName whereKey:secondaryCoreDataKey isIn:secondaryKeySet] mutableCopy];
    NSMutableArray *entitySecondaryIDs = [[secondaryEntitiesToUpdate valueForKey:secondaryCoreDataKey] mutableCopy];
    
	
	for ( id JSONObject in JSONObjects ) {
		NSString *IDString = [JSONObject valueForKey:JSONKey];
        NSString* secondaryIDString = [JSONObject valueForKey:secondaryJSONKey];
        
		id ID = nil;        
        if ([[primaryKeyDict objectForKey:@"kind"] isEqualToString:@"Integer"]) {
            ID = [NSNumber numberWithInt:[IDString intValue]];
        } else {
            ID = IDString;
        }
        
		id entity = nil;
		NSInteger index = [entityUniqueIDs indexOfObject:ID];
		if ( index != NSNotFound && ![entityName isEqualToString:@"BGScorecard"])
			entity = [entitiesToUpdate objectAtIndex:index];
		else {
            
            id secondaryID = secondaryIDString;

            index = [entitySecondaryIDs indexOfObject:secondaryID];
            if ( index != NSNotFound && ![entityName isEqualToString:@"BGScorecard"]){
                
                entity = [secondaryEntitiesToUpdate objectAtIndex:index];
                [entitiesToUpdate addObject:entity];
                [entityUniqueIDs addObject:ID];
                
            }else{
                
                entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
                if ( ID && entity ) {
                    [entitiesToUpdate addObject:entity];
                    [entityUniqueIDs addObject:ID];
                    [secondaryEntitiesToUpdate addObject:entity];
                    [entitySecondaryIDs addObject:secondaryID];
                }
            }
                
		}
		
        
		for ( NSDictionary *keyDict in syncDictionaries ) {
			NSString *coreDataKey = [keyDict objectForKey:@"CoreDataKey"];
			NSString *JSONKey = [keyDict objectForKey:@"JSONKey"];
			
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
			
			if ( !value )
				continue;
            
                 
			NSString *relationshipEntity = [keyDict objectForKey:@"CoreDataRelationshipEntity"];
			if ( relationshipEntity ) {
				NSString *relationshipKey = [keyDict objectForKey:@"CoreDataRelationshipKey"];
				NSString *relationshipSelectorString = [keyDict objectForKey:@"CoreDataRelationshipMethod"];
				SEL relationshipSelector = NSSelectorFromString(relationshipSelectorString);
				if ( [entity respondsToSelector:relationshipSelector] ) {
				
					id relatedObject = [moc entityWithName:relationshipEntity whereKey:relationshipKey equalToObject:value];
				
					if (!relatedObject)
						continue;
					[entity performSelector:relationshipSelector withObject:relatedObject];
				}
			}
			else {
				[entity setValue:value forKey:coreDataKey];
			}
		}
	}

	[entitiesToUpdate release];
	[entityUniqueIDs release];
    [secondaryEntitiesToUpdate release];
    [entitySecondaryIDs release];
	
	return YES;
bail:
	return NO;
}

- (void)saveData {
	NSError *error = nil;
	[[self managedObjectContext] save:&error];
	if ( error ) {
		FJSLog(@"%@", error);
		error = nil;
	}
}

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

    
    /*
    NSMutableArray* allKeysAsNumbers = [NSMutableArray arrayWithCapacity:[uniqueKeySet count]];
    [uniqueKeySet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    
        NSString* key = obj;
        int intVal = [key intValue];
        NSNumber* num = [NSNumber numberWithInt:intVal];
        [allKeysAsNumbers addObject:num];
        
    }];
    
    
    [allKeysAsNumbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [allIDs enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx, BOOL *stop) {
        
            if([obj isEqualToNumber:obj2]){
                
                NSLog(@"found! %@ %@", [obj description], [obj2 description]);

            }
   
        }];
        
        if([allIDs containsObject:obj]){
            
        }
        
    
    }];
    */
    
    
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
	
- (void)updateLoadedData {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
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
        
        NSString *JSONSyncPath = [[NSBundle mainBundle] pathForResource:@"JSONSync" ofType:@"plist"];
        NSDictionary *JSONSyncDict = [NSDictionary dictionaryWithContentsOfFile:JSONSyncPath];
        

        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([organizations count] > 0 || [brands count] > 0){
                
                [self addSplashScreen];
                
                [self.hud hide:NO];
                [self.hud removeFromSuperview];
                self.hud = [[MBProgressHUD alloc] initWithWindow:self.window];
                self.hud.labelText = @"Updating. Please wait…";
                [self.window addSubview:self.hud];
                [self.hud show:YES];
            }
            
            
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self syncEntity:@"BGCategory" withJSONObjects:categories syncDictionaries:[JSONSyncDict objectForKey:@"BGCategory"]];
                [self saveData];
                [self syncEntity:@"BGCompany" withJSONObjects:organizations syncDictionaries:[JSONSyncDict objectForKey:@"BGCompany"]];
                [self saveData];
                [self syncEntity:@"BGBrand" withJSONObjects:brands syncDictionaries:[JSONSyncDict objectForKey:@"BGBrand"]];
                [self saveData];
                
                if([organizations count] > 0 || [brands count] > 0){
                    [self syncEntity:@"BGScorecard" withJSONObjects:scorecards syncDictionaries:[JSONSyncDict objectForKey:@"BGScorecard"]];
                    [self saveData];
                }
                
                [self markOrganizationsAsDeletedWithJSON:removed];
                [self saveData];
                
                
                NSDate *lastUpdateDate = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:lastUpdateDate forKey:kLastUpdateDateKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self.navigationController popViewControllerAnimated:NO];
                MainViewController *rootViewController = (MainViewController *)[navigationController topViewController];
                rootViewController.managedObjectContext = self.managedObjectContext;
                [rootViewController.categoryView fetchAndReload];
                [rootViewController.companyView fetchAndReload];
                [rootViewController.modeSwitch setSelectedSegmentIndex:0];
                [rootViewController loadCategories];
                
                
                [self dataUpdateDidFinish];
                
            });
            
        });
            
        });
        
        
           
   
    
    
	    
}


- (void)updateLoadedDataInBackground { 
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self updateLoadedData];
	[pool drain];
}

- (void)updateDataWFromLocalJSON {
    
    /*
    [managedObjectContext release];
    managedObjectContext = nil;
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
    [managedObjectModel release];
    managedObjectModel = nil;
    
    NSString* currentAppDB = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"];
    [[NSFileManager defaultManager] removeItemAtPath:currentAppDB error:nil];
    
    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	rootViewController.managedObjectContext = self.managedObjectContext;
     
     */
    
       
    NSString* path = [[NSBundle mainBundle] pathForResource:@"TestJSON" ofType:@"txt"];	
    NSMutableData* d = [[NSMutableData alloc] initWithContentsOfFile:path];
    _updateData = d;
    
    [self performSelectorOnMainThread:@selector(updateLoadedData) withObject:nil waitUntilDone:NO];

}

- (void)updateDataWithLastUpdateDate:(NSDate *)lastUpdate; {
        
    self.start = [NSDate date]; 
    
    
	NSString *URLString = @"http://fj.hrc.org/app_connect2.php?content-type=json&key=41e97990456ae2eb1b5bacb69e86685c";
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
        [components setYear:2012];
        [components setMonth:03];
        [components setDay:28];
        [components setHour:12];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *lastUpdateDate = [components date];
        
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateDate forKey:kLastUpdateDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [components release];
        
    }
}

/*
- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    for (NSManagedObject *managedObject in items) {
        [_managedObjectContext deleteObject:managedObject];
        DLog(@"%@ object deleted",entityDescription);
    }
    if (![_managedObjectContext save:&error]) {
        DLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}
*/



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
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
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


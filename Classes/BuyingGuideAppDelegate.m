//
//  BuyingGuideAppDelegate.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/15/09.
//  Copyright Flying Jalapeño Software 2009. All rights reserved.
//

#import "BuyingGuideAppDelegate.h"
#import "MainViewController.h"
#import "FlurryAPI.h"
#import "RootViewController.h"
#import "JSON.h"
#import "NSManagedObjectContext+Extensions.h"
#import "BGBrand.h"
#import "BGCompany.h"

#define UPDATE_INTERVAL 604800

@interface BuyingGuideAppDelegate ()
- (void) dataUpdateDidFinish;
@end

@implementation BuyingGuideAppDelegate

static NSString* kAnimationID = @"SplashAnimation";

@synthesize window;
@synthesize navigationController;
@synthesize splashView;


+ (void)initialize {
	if ( self == [BuyingGuideAppDelegate class] ) {
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setCalendar:[NSCalendar currentCalendar]];
		[components setDay:2];
		[components setMonth:1];
		[components setYear:2011];
		NSDate *date = [components date];
		if ( date ) {
			NSDictionary *defaults = [NSDictionary dictionaryWithObject:date forKey:@"LastUpdate"];
			[components release];
			[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
		}
	}
}




#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Override point for customization after app launch    
	BOOL forceUpdate = NO;
	
	[self loadDataForce:forceUpdate];
	
	if ( forceUpdate || [[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"LastUpdate"]] > UPDATE_INTERVAL	)
		[self updateData];
	else
		[self dataUpdateDidFinish];
	
	[FlurryAPI startSession:@"4bbfd488141c84699824c518b281b86e"];
    [FlurryAPI setSessionReportsOnCloseEnabled:NO];
	RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	rootViewController.managedObjectContext = self.managedObjectContext;
	[window addSubview:[navigationController view]];
	[self addSplashScreen];
	[window makeKeyAndVisible];
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
	UIImageView *localSplashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
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

- (NSNumberFormatter *)integerFormatter {
	if ( !_integerFormatter ) {
		_integerFormatter = [[NSNumberFormatter alloc] init];
	}
	return _integerFormatter;
}

- (BOOL)syncEntity:(NSString *)entityName withJSONObjects:(NSArray *)JSONObjects syncDictionaries:(NSArray *)syncDictionaries {
	if ( !syncDictionaries || ![syncDictionaries count] || !entityName || !JSONObjects )
		goto bail;
	
	NSDictionary *primaryKeyDict = [syncDictionaries objectAtIndex:0];
	
	NSString *coreDataKey = [primaryKeyDict valueForKey:@"CoreDataKey"];
	NSString *JSONKey = [primaryKeyDict valueForKey:@"JSONKey"];
	
	NSFormatter *uniqueIDFormatter = ([[primaryKeyDict objectForKey:@"kind"] isEqualToString:@"Integer"] ? [self integerFormatter] : nil );
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSMutableSet *uniqueKeySet = [NSMutableSet setWithArray:[JSONObjects valueForKey:JSONKey]];
	[uniqueKeySet removeObject:[NSNull null]];
	
	NSArray *entitesToUpdate = [moc entitiesWithName:entityName whereKey:coreDataKey isIn:uniqueKeySet];
	NSArray *entityUniqueIDs = [entitesToUpdate valueForKey:coreDataKey];
	
	NSUInteger count = [entitesToUpdate count];
	for ( id JSONObject in JSONObjects ) {
		NSString *IDString = [JSONObject valueForKey:JSONKey];
		id ID = nil;
		if ( uniqueIDFormatter )
			[uniqueIDFormatter getObjectValue:&ID forString:IDString errorDescription:nil];
		else
			ID = IDString;
		
		id entity = nil;
		NSInteger index = [entityUniqueIDs indexOfObject:ID];
		if ( index < count )
			entity = [entitesToUpdate objectAtIndex:index];
		else 
			entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
		
		for ( NSDictionary *keyDict in syncDictionaries ) {
			NSString *coreDataKey = [keyDict objectForKey:@"CoreDataKey"];
			NSString *JSONKey = [keyDict objectForKey:@"JSONKey"];
			id value = nil;
			id JSONValue = [JSONObject valueForKey:JSONKey];
			
			NSFormatter *formatter = ( [[keyDict valueForKey:@"kind"] isEqualToString:@"Integer"] ? [self integerFormatter] : nil );
			if ( formatter )
				[formatter getObjectValue:&value forString:JSONValue errorDescription:nil];
			else
				value = JSONValue;
			
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

	return YES;
bail:
	return NO;
}

- (void)updateLoadedData {
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *updateDict = [parser objectWithData:_updateData];
	[parser release];
	[_updateData release];
	_updateData = nil;
	
	NSArray *brands = [[updateDict valueForKeyPath:@"brands"] valueForKey:@"row"];
	NSArray *categories = [[updateDict valueForKeyPath:@"categories"] valueForKey:@"row"];
	NSArray *organizations = [[updateDict valueForKeyPath:@"organizations"] valueForKey:@"row"];
	
	NSString *JSONSyncPath = [[NSBundle mainBundle] pathForResource:@"JSONSync" ofType:@"plist"];
	NSDictionary *JSONSyncDict = [NSDictionary dictionaryWithContentsOfFile:JSONSyncPath];
	
	[self syncEntity:@"BGCategory" withJSONObjects:categories syncDictionaries:[JSONSyncDict objectForKey:@"BGCategory"]];
	[self syncEntity:@"BGCompany" withJSONObjects:organizations syncDictionaries:[JSONSyncDict objectForKey:@"BGCompany"]];
	[self syncEntity:@"BGBrand" withJSONObjects:brands syncDictionaries:[JSONSyncDict objectForKey:@"BGBrand"]];
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSArray *allCompanies = [moc entitiesWithName:@"BGCompany"];
	
	//Need to create brands for companies whose name is the brand
	//So, find all companies where brands is nil or brand count is 0
	for ( BGCompany *company in allCompanies ) {
		if ( !company.brands || ![company.brands count] ) {
			BGBrand *brand = [NSEntityDescription insertNewObjectForEntityForName:@"BGBrand" inManagedObjectContext:moc];
			brand.name = company.name;
			[brand addCompaniesObject:company];
		}
	}
	
	NSError *error = nil;
	[[self managedObjectContext] save:&error];
	
	if ( error )
		FJSLog(@"%@", error);
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdate"];
	
	[self dataUpdateDidFinish];
}


- (void)updateLoadedDataInBackground { 
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self updateLoadedData];
	[pool drain];
}

- (void)updateData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *lastUpdate = [defaults objectForKey:@"LastUpdate"];
	NSString *URLString = @"http://fj.hrc.org/app_connect.php?content-type=json";
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

- (void)loadDataForce:(BOOL)flag{

    NSString* staticDB = [[NSBundle mainBundle] pathForResource:@"storedata" ofType:@"sqlite"];
	NSString* appDB = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"];
	
    NSDictionary* oldAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:staticDB error:nil];
	NSDictionary* newAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:appDB error:nil];

	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
	
	NSString* oldBundleID = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString*)kCFBundleVersionKey];
	NSString* newBundleID = [info objectForKey:(NSString*)kCFBundleVersionKey];
    
    if( flag ){
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LastUpdate"];
		[[NSFileManager defaultManager] removeItemAtPath:appDB error:nil];
        if ( staticDB )
			[[NSFileManager defaultManager] copyItemAtPath:staticDB 
                                                toPath:appDB 
                                                 error:nil];
    }else{
		
		if(newAttributes == nil && staticDB){
			
			[[NSFileManager defaultManager] removeItemAtPath:appDB error:nil];
			[[NSFileManager defaultManager] copyItemAtPath:staticDB 
													toPath:appDB 
													 error:nil];
			
		}else if(![newBundleID isEqualToString:oldBundleID] && staticDB){
			
			
			[[NSFileManager defaultManager] removeItemAtPath:appDB error:nil];
			[[NSFileManager defaultManager] copyItemAtPath:staticDB 
													toPath:appDB 
													 error:nil];
			
		}else if(![(NSDate*)[oldAttributes objectForKey:NSFileCreationDate] isEqualToDate:(NSDate*)[newAttributes objectForKey:NSFileCreationDate]] && staticDB ){
			
			[[NSFileManager defaultManager] removeItemAtPath:appDB error:nil];
			[[NSFileManager defaultManager] copyItemAtPath:staticDB 
													toPath:appDB 
													 error:nil];
		}
    }
	
	[[NSUserDefaults standardUserDefaults] setObject:newBundleID forKey:(NSString*)kCFBundleVersionKey];

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
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
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
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
        
        [self loadDataForce:YES];
        
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
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    self.splashView = nil;
	
    [_integerFormatter release];
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


//
//  BuyingGuideAppDelegate.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/15/09.
//  Copyright Flying Jalapeño Software 2009. All rights reserved.
//

#import "BuyingGuideAppDelegate.h"
#import "MainViewController.h"


@implementation BuyingGuideAppDelegate

static NSString* kAnimationID = @"SplashAnimation";

@synthesize window;
@synthesize navigationController;
@synthesize splashView;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
        
    // Override point for customization after app launch    

    [self loadDataForce:NO];
    
	MainViewController *rootViewController = (MainViewController *)[navigationController topViewController];
	rootViewController.context = self.managedObjectContext;
	
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
    
	[self performSelector:@selector(removeSplashScreen) withObject:nil afterDelay:0.1];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
    if([animationID isEqualToString:kAnimationID]){
        
        [self.splashView removeFromSuperview];
        self.splashView = nil;
        
    }
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

- (void)loadDataForce:(BOOL)flag{

    NSString* db = [[NSBundle mainBundle] pathForResource:@"storedata" ofType:@"sqlite"];
    
    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"] error:nil];
    
    if(flag){
        [[NSFileManager defaultManager] copyItemAtPath:db 
                                                toPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"] 
                                                 error:nil];
    }else{
        
        if([(NSNumber*)[attributes objectForKey:NSFileSize] longValue] < 200){
            
            [[NSFileManager defaultManager] copyItemAtPath:db 
                                                    toPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"storedata.sqlite"] 
                                                     error:nil];
            
        }
        
        
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
            abort();
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
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[navigationController release];
	[window release];
	[super dealloc];
}


@end


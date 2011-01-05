//
//  BuyingGuideAppDelegate.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/15/09.
//  Copyright Flying Jalapeño Software 2009. All rights reserved.
//

@interface BuyingGuideAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    UINavigationController *navigationController;
    UIView* splashView;
	
	NSURLConnection *_updateConnection;
	NSMutableData *_updateData;
	
	NSNumberFormatter *_integerFormatter;
	
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic,retain)UIView *splashView;

- (NSString *)applicationDocumentsDirectory;
- (void)loadDataForce:(BOOL)flag;
- (void)updateDataWithLastUpdateDate:(NSDate *)lastUpdate;
- (void)addSplashScreen;

@end


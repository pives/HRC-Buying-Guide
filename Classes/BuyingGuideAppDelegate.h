//
//  BuyingGuideAppDelegate.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/15/09.
//  Copyright Flying Jalapeño Software 2009. All rights reserved.
//

@class MBProgressHUD;

@interface BuyingGuideAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    UINavigationController *navigationController;
    UIView* splashView;
    
    MBProgressHUD* hud;
	
	NSURLConnection *_updateConnection;
	NSMutableData *_updateData;
	    
    NSDate* start;
	
}
@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic,retain)UIView *splashView;

@property (nonatomic, copy) NSDate *start;


- (NSString *)applicationDocumentsDirectory;
- (void)loadDataBaseCopyFromBundleForce:(BOOL)flag;
- (void)updateDataWithLastUpdateDate:(NSDate *)lastUpdate;
- (void)addSplashScreen;

- (void)saveData;

@end


//
//  BGImporter_AppDelegate.h
//  BGImporter
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright Flying Jalapeño Software 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BGImporter_AppDelegate : NSObject <NSApplicationDelegate> 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;

@end

//
//  FilteredCompaniesTableViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilteredCompaniesTableViewController : UITableViewController {

    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSString* filterKey;
    id filterObject;
    
    UISegmentedControl* sortControl;
    
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)NSString *filterKey;
@property(nonatomic,retain)id filterObject;
@property(nonatomic,retain)UISegmentedControl *sortControl;


- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object;
- (IBAction)changeSort:(id)sender;


@end

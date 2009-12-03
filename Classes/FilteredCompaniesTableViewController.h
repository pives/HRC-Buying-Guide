//
//  FilteredCompaniesTableViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    FilterdTableViewControllerModeRating = 0, //Default
    FilterdTableViewControllerModeAlphabetically = 1
} FilterdTableViewControllerMode;


@interface FilteredCompaniesTableViewController : UITableViewController {

    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSString* filterKey;
    id filterObject;
    
    NSArray* cellColors;
    
    FilterdTableViewControllerMode mode;
    
    
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)NSString *filterKey;
@property(nonatomic,retain)id filterObject;
@property (nonatomic,retain) NSArray *cellColors;
@property(nonatomic,assign)FilterdTableViewControllerMode mode;


- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object;
- (void)fetch;

- (NSIndexPath*)sectionIndexOfRedSection;
- (NSIndexPath*)sectionIndexOfYellowSection;
- (NSIndexPath*)sectionIndexOfGreenSection;

@end


extern NSString *const DidSelectFilteredCompanyNotification;
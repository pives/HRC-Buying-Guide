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

    NSFetchedResultsController *ratingFetchedResultsController;
	NSFetchedResultsController *nameFetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSString* filterKey;
    id filterObject;
    
    NSArray* cellColors;
    
    FilterdTableViewControllerMode mode;
	
	NSFetchedResultsController *searchResultsController;
	BOOL searching;
    
    
}
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,retain)NSFetchedResultsController *ratingFetchedResultsController;
@property(nonatomic,retain)NSFetchedResultsController *nameFetchedResultsController;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)NSString *filterKey;
@property(nonatomic,retain)id filterObject;
@property (nonatomic,retain) NSArray *cellColors;
@property(nonatomic,assign)FilterdTableViewControllerMode mode;
@property(nonatomic,retain)NSFetchedResultsController *searchResultsController;
@property(nonatomic,assign)BOOL searching;

- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object;
- (void)fetch;
- (void)reload;

- (NSIndexPath*)sectionIndexOfRedSection;
- (NSIndexPath*)sectionIndexOfYellowSection;
- (NSIndexPath*)sectionIndexOfGreenSection;

- (NSFetchedResultsController*)alphabeticalSearchResultsControllerForString:(NSString*)searchString;
- (NSFetchedResultsController*)ratingSearchResultsControllerForString:(NSString*)searchString;

@end


extern NSString *const DidSelectFilteredBrandNotification;
extern NSString *const FilteredCompanySearchBegan;
extern NSString *const FilteredCompanySearchEnded;
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

@class BGCategory;
@class BGCompany;

@interface FilteredCompaniesTableViewController : UITableViewController {

    NSFetchedResultsController *ratingFetchedResultsController;
	NSFetchedResultsController *nameFetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    
    NSArray* cellColors;
    
    FilterdTableViewControllerMode mode;
	
	NSFetchedResultsController *searchResultsController;
	BOOL searching;
    
    
}
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,retain)NSFetchedResultsController *ratingFetchedResultsController;
@property(nonatomic,retain)NSFetchedResultsController *nameFetchedResultsController;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)BGCategory *filterCategory;
@property(nonatomic,retain)BGCompany *filterCompany;
@property (nonatomic,retain) NSArray *cellColors;
@property(nonatomic,assign)FilterdTableViewControllerMode mode;
@property(nonatomic,retain)NSFetchedResultsController *searchResultsController;
@property(nonatomic,assign)BOOL searching;

- (id)initWithContext:(NSManagedObjectContext*)context filteredOnCategory:(BGCategory *)category filteredOnCompany:(BGCompany *)company;
- (void)fetch;
- (void)reload;

- (NSIndexPath*)sectionIndexOfRedSection;
- (NSIndexPath*)sectionIndexOfYellowSection;
- (NSIndexPath*)sectionIndexOfGreenSection;

- (NSFetchedResultsController*)alphabeticalSearchResultsControllerForString:(NSString*)searchString;
- (NSFetchedResultsController*)ratingSearchResultsControllerForString:(NSString*)searchString;

- (NSPredicate *)predicate;

@end


extern NSString *const DidSelectFilteredBrandNotification;
extern NSString *const FilteredCompanySearchBegan;
extern NSString *const FilteredCompanySearchEnded;
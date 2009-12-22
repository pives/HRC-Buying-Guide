//
//  RootViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/21/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRCSearchResultsController.h"
#import "HRCCategoriesResultsController.h"
#import "HRCCompaniesResultsController.h"

typedef enum {
	
	HRCTableViewModeCategories = 0,
	HRCTableViewModeCompanies = 1,
	THRCableViewModeSearch = 3
	
}HRCTableViewMode;

@interface RootViewController : UITableViewController {
	
	NSManagedObjectContext *managedObjectContext;
    NSArray* cellColors;
	
	HRCSearchResultsController *searchResultsController;
	HRCCompaniesResultsController *companiesResultsController;
	HRCCategoriesResultsController *categoriesResultsController;
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
	
	HRCTableViewMode mode;
	
	UISegmentedControl* modeSwitch;

	
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSArray *cellColors;

@property(nonatomic,retain)HRCSearchResultsController *searchResultsController;
@property(nonatomic,retain)HRCCompaniesResultsController *companiesResultsController;
@property(nonatomic,retain)HRCCategoriesResultsController *categoriesResultsController;

@property(nonatomic,assign)IBOutlet UISegmentedControl *modeSwitch;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@property(nonatomic,assign)HRCTableViewMode mode;


- (void)toggleViews:(id)sender;
- (void)preloadAllBrandsFetchedResultsController;

@end


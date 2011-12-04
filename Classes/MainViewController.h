//
//  MainViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoriesTableViewController;
@class CompaniesTableViewController;
@class BrandViewController;

@interface MainViewController : UIViewController {

    CategoriesTableViewController* categoryView;
    CompaniesTableViewController* companyView;
	BrandViewController* companyController;
    UISegmentedControl* modeSwitch;
    
    NSManagedObjectContext* managedObjectContext;
        
}
@property(nonatomic,retain)CategoriesTableViewController *categoryView;
@property(nonatomic,retain)CompaniesTableViewController *companyView;
@property(nonatomic,assign)IBOutlet UISegmentedControl *modeSwitch;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)BrandViewController *brandController;


- (void)toggleViews:(id)sender;
- (void)loadCategories;
- (void)loadCompanies;
- (void)preloadAllBrandsFetchedResultsController;

@end

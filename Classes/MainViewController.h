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

@interface MainViewController : UIViewController {

    CategoriesTableViewController* categoryView;
    CompaniesTableViewController* companyView;
    UISegmentedControl* modeSwitch;
    
    NSManagedObjectContext* context;
        
}
@property(nonatomic,retain)CategoriesTableViewController *categoryView;
@property(nonatomic,retain)CompaniesTableViewController *companyView;
@property(nonatomic,assign)IBOutlet UISegmentedControl *modeSwitch;
@property(nonatomic,retain)NSManagedObjectContext *context;


- (void)toggleViews:(id)sender;
- (void)loadCategories;
- (void)loadCompanies;

@end

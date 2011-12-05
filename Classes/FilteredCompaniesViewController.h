//
//  FilteredCompaniesViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/3/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJSTableViewColorIndex.h"
#import "FJSTableViewImageIndex.h"

@class FilteredCompaniesTableViewController;
@class BrandViewController;
@class BGCompany;
@class BGCategory;

@interface FilteredCompaniesViewController : UIViewController <FJSTableViewImageIndexDelegate>{
    
    FJSTableViewImageIndex* index;
    
    UISegmentedControl* sortControl;
    
    FilteredCompaniesTableViewController* tableController;
	BrandViewController* companyController;

}
@property(nonatomic,retain)FJSTableViewImageIndex *index;
@property(nonatomic,retain)UISegmentedControl *sortControl;
@property(nonatomic,retain)FilteredCompaniesTableViewController *tableController;
@property(nonatomic,retain)BrandViewController *companyController;


- (id)initWithContext:(NSManagedObjectContext*)context filteredOnCategory:(BGCategory *)category filteredOnCompany:(BGCompany *)company;
- (IBAction)changeSort:(id)sender;


@end

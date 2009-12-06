//
//  FilteredCompaniesViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/3/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJSTableViewColorIndex.h"
@class FilteredCompaniesTableViewController;

@interface FilteredCompaniesViewController : UIViewController <FJSTableViewColorIndexDelegate>{
    
    FJSTableViewColorIndex* index;
    
    UISegmentedControl* sortControl;
    
    FilteredCompaniesTableViewController* tableController;

}
@property(nonatomic,retain)FJSTableViewColorIndex *index;
@property(nonatomic,retain)UISegmentedControl *sortControl;
@property(nonatomic,retain)FilteredCompaniesTableViewController *tableController;


- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object;
- (IBAction)changeSort:(id)sender;


@end

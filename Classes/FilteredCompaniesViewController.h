//
//  FilteredCompaniesViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/3/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilteredCompaniesTableViewController;

@interface FilteredCompaniesViewController : UIViewController {

    UIButton* red;
    UIButton* yellow;
    UIButton* green;
    
    UISegmentedControl* sortControl;
    
    FilteredCompaniesTableViewController* tableController;

}
@property(nonatomic,retain) UIButton *red;
@property(nonatomic,retain) UIButton *yellow;
@property(nonatomic,retain) UIButton *green;
@property(nonatomic,retain)UISegmentedControl *sortControl;
@property(nonatomic,retain)FilteredCompaniesTableViewController *tableController;


- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object;
- (IBAction)changeSort:(id)sender;


@end

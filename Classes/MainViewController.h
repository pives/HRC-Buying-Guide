//
//  MainViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoriesTableViewController;

@interface MainViewController : UIViewController {

    CategoriesTableViewController* categoryView;
    
    UISegmentedControl* modeSwitch;
    
    NSManagedObjectContext* context;
    
}
@property(nonatomic,retain)CategoriesTableViewController *categoryView;
@property(nonatomic,assign)IBOutlet UISegmentedControl *modeSwitch;
@property(nonatomic,retain)NSManagedObjectContext *context;



@end

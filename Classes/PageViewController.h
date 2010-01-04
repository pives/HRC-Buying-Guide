//
//  PageViewController.h
//  PagingScrollView
//
//  Created by Matt Gallagher on 24/01/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
@class HRCBrandTableDataSource;
@class Company;
@class Category;
@class HRCBrandTableViewController;

@interface PageViewController : UIViewController {
    
	NSInteger pageIndex;
	BOOL textViewNeedsUpdate;
	    
    HRCBrandTableDataSource* data;
    
    Company* company;
    Category* category;
    
    UILabel* categoryName;
    
	NSManagedObjectContext *managedObjectContext;
    
    UIColor* ratingColor;
    
    HRCBrandTableViewController* tableController;
}

@property NSInteger pageIndex;
@property(nonatomic,retain)HRCBrandTableDataSource *data;
@property(nonatomic,retain)Company *company;
@property(nonatomic,retain)Category *category;
@property(nonatomic,assign)IBOutlet UILabel *categoryName;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)UIColor *ratingColor;
@property(nonatomic,retain)HRCBrandTableViewController *tableController;




- (id)initWithDataSource:(HRCBrandTableDataSource*)someData;

@end

//
//  PageTableViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/24/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Company;
@class Category;

@interface PageTableViewController : UITableViewController {
    
    Company* company;
    Category* category;
    
    UIColor* ratingColor;
    
    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

}
@property(nonatomic,retain)Company *company;
@property(nonatomic,retain)Category *category;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)UIColor *ratingColor;

- (id)initWithStyle:(UITableViewStyle)style company:(Company*)aCompany category:(Category*)aCategory color:(UIColor*)aColor;
- (void)fetch;


@end
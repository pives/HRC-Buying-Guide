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

@interface HRCBrandTableViewController : UITableViewController {
    
    Company* company;
    Category* category;
    
    UIColor* ratingColor;
    
    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    
    CGRect tableFrame;

}
@property(nonatomic,retain)Company *company;
@property(nonatomic,retain)Category *category;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)UIColor *ratingColor;
@property(nonatomic,assign)CGRect tableFrame;


- (id)initWithStyle:(UITableViewStyle)style company:(Company*)aCompany category:(Category*)aCategory color:(UIColor*)aColor;
- (void)setCompany:(Company*)aCompany category:(Category*)aCategory color:(UIColor*)aColor;
- (void)fetch;


@end


extern NSString *const BrandsTableCategoryButtonTouchedNotification;
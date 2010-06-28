//
//  PageTableViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/24/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGCompany;
@class BGCategory;

@interface HRCBrandTableViewController : UITableViewController {
    
    BGCompany* company;
    BGCategory* category;
    
    UIColor* ratingColor;
    
    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    
    CGRect tableFrame;

}
@property(nonatomic,retain)BGCompany *company;
@property(nonatomic,retain)BGCategory *category;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain)UIColor *ratingColor;
@property(nonatomic,assign)CGRect tableFrame;


- (id)initWithStyle:(UITableViewStyle)style company:(BGCompany*)aCompany category:(BGCategory*)aCategory color:(UIColor*)aColor;
- (void)setCompany:(BGCompany*)aCompany category:(BGCategory*)aCategory color:(UIColor*)aColor;
- (void)fetch;


@end


extern NSString *const BrandsTableCategoryButtonTouchedNotification;
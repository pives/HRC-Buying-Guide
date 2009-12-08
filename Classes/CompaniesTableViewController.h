//
//  CompaniesTableViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//


@interface CompaniesTableViewController : UITableViewController {
    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSArray* cellColors;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSArray *cellColors;

- (void)fetch;

@end


extern NSString *const DidSelectCompanyNotification;
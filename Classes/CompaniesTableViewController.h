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
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

extern NSString *const DidSelectCompanyNotification;
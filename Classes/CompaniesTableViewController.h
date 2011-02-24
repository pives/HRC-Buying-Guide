//
//  CompaniesTableViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//


@interface CompaniesTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSArray* cellColors;
		
	NSFetchedResultsController *searchResultsController;
	BOOL searching;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSArray *cellColors;

@property(nonatomic,retain)NSFetchedResultsController *searchResultsController;
@property(nonatomic,assign)BOOL searching;

- (void)fetchAndReload;

@end


extern NSString *const DidSelectCompanyNotification;
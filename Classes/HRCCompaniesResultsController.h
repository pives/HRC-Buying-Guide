//
//  HRCCompaniesResultsController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/22/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HRCCompaniesResultsController : NSObject <NSFetchedResultsControllerDelegate, 
														UITableViewDelegate, 
														UITableViewDataSource> 
{
	
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    NSArray* cellColors;
	
	NSFetchedResultsController *searchResultsController;
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
	
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSArray *cellColors;

@property(nonatomic,retain)NSFetchedResultsController *searchResultsController;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

- (void)fetch;



@end

//
//  HRCCategoriesResultsController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/22/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HRCCategoriesResultsController : NSObject <NSFetchedResultsControllerDelegate, 
														UITableViewDelegate, 
														UITableViewDataSource> 

{
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)fetch;

@end



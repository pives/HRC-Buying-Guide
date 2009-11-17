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
@class DataSource;
@class Company;
@class Category;

@interface PageViewController : UITableViewController
{
	NSInteger pageIndex;
	BOOL textViewNeedsUpdate;
	    
    DataSource* data;
    
    Company* company;
    Category* category;
    
    NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    
}

@property NSInteger pageIndex;
@property(nonatomic,retain)DataSource *data;
@property(nonatomic,retain)Company *company;
@property(nonatomic,retain)Category *category;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;



- (id)initWithDataSource:(DataSource*)someData;

@end

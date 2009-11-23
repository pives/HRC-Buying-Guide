//
//  PageViewController.m
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

#import "PageViewController.h"
#import "DataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "Company.h"
#import "Company+Extensions.h"
#import "ColoredTableViewCell.h"
#import "UIColor+extensions.h"

const CGFloat TEXT_VIEW_PADDING = 50.0;

@implementation PageViewController

@synthesize pageIndex;
@synthesize data;
@synthesize company;
@synthesize category;
@synthesize table;
@synthesize categoryName;

@synthesize fetchedResultsController, managedObjectContext;


#pragma mark -
#pragma mark Memory management

- (void) dealloc
{
    
    self.table = nil;
    self.categoryName = nil;
    self.company = nil;
    self.category = nil;
    self.data = nil;
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}

- (id)initWithDataSource:(DataSource*)someData{
    
    if(self = [super init]){
        
        self.data = someData;
        self.company = data.company;
        self.managedObjectContext = company.managedObjectContext;
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.table.separatorColor = [UIColor whiteColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    categoryName.textColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

}


- (void)fetch{
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[fetchedResultsController sections] count];
    return (count == 0) ? 1 : count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ColoredTableViewCell *cell = (ColoredTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ColoredTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    
    if([company.ratingLevel intValue] == 0)
        cell.cellColor = [UIColor gpGreen];
    else if([company.ratingLevel intValue] == 1)
        cell.cellColor = [UIColor gpYellow];
    else
        cell.cellColor = [UIColor gpRed];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [managedObject valueForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
     */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Brand" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    if(category==nil)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"company == %@", self.company]];
    else 
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"company == %@ AND (%@ IN categories)", self.company, self.category]];

	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:@"BrandView"];
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
} 


- (void)setPageIndex:(NSInteger)newPageIndex
{
	pageIndex = newPageIndex;
    
    self.categoryName.font = [UIFont boldSystemFontOfSize:14];
	
	if (pageIndex >= 0 && pageIndex < ([data numDataPages]))
	{
        
        if(pageIndex == 0){
                        
            self.category = nil;
            self.categoryName.text = @"All Brands";
            
        }else{
            
            self.category = [company.categoriesSortedAlphabetically objectAtIndex:(pageIndex-1)];     
            self.categoryName.text = self.category.name;

        }
        
        [self fetch];
    }
}
@end


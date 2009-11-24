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
@synthesize ratingColor;



@synthesize fetchedResultsController, managedObjectContext;


#pragma mark -
#pragma mark Memory management

- (void) dealloc
{
    self.ratingColor = nil;    
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
        
        if([company.ratingLevel intValue] == 0)
            self.ratingColor = [UIColor gpGreen];
        else if([company.rating intValue] == 1)
            self.ratingColor = [UIColor gpYellow];
        else 
            self.ratingColor = [UIColor gpRed];

    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    //TODO: manually create table
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        //TODO: fix cell outlines
        
        UIView* background = [[UIView alloc] initWithFrame:cell.bounds];
        background.backgroundColor = [UIColor whiteColor];
        UIView* foreground = [[UIView alloc] initWithFrame:CGRectMake(cell.bounds.origin.x+1, 
                                                                      cell.bounds.origin.y+1, 
                                                                      cell.bounds.size.width-10,
                                                                      cell.bounds.size.height-2)];
        
        foreground.backgroundColor = self.ratingColor;
        [background addSubview:foreground];
        cell.backgroundView = background;
        [foreground release];
        [background release];
        
        
        
        UILabel* brand = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 230, cell.frame.size.height)];
        brand.tag = 1000;
        brand.font = [UIFont boldSystemFontOfSize:14];
        brand.textColor = [UIColor blackColor];
        brand.textAlignment = UITextAlignmentLeft;
        brand.backgroundColor = [UIColor clearColor];
        [cell addSubview:brand];
        [brand release];
                
    }
    
    // Configure the cell.
    
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    UILabel* brand = (UILabel*)[cell viewWithTag:1000];    
	brand.text = [managedObject valueForKey:@"name"];
    
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


//
//  PageTableViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/24/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "PageTableViewController.h"
#import "Company.h"
#import "Category.h"
#import "UIColor+extensions.h"

@implementation PageTableViewController

@synthesize company;
@synthesize category;
@synthesize ratingColor;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize tableFrame;



- (void) dealloc
{
    self.company = nil;
    self.category = nil;
    self.ratingColor = nil;
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
    [super dealloc];
}




- (id)initWithStyle:(UITableViewStyle)style company:(Company*)aCompany category:(Category*)aCategory color:(UIColor*)aColor{
    
    if(self = [super init]){
        
        self.company = aCompany;
        self.managedObjectContext = company.managedObjectContext;
        self.category = aCategory;
        self.ratingColor = aColor;

    }
    return self;
}



- (void)setTableFrame:(CGRect)aFrame{
    
    tableFrame = aFrame;
    [self.view setFrame:tableFrame];
    [self.tableView setFrame:tableFrame];
    
}

- (void)loadView{
    
    self.view = [[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor reallyLightGray];
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //TODO: Makes me crash when switching tableviews IF the brand table is empty (company name is in the cat but no brand)
    /*
    if([self.tableView visibleCells] != nil || ([[self.tableView visibleCells] count] > 0))
       [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    */
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
    
    [self.tableView reloadData];

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
        UIView* foreground = [[UIView alloc] initWithFrame:CGRectMake(1, 
                                                                      1, 
                                                                      cell.frame.size.width-2,
                                                                      cell.frame.size.height-2)];
        
        foreground.backgroundColor = self.ratingColor;
        [background addSubview:foreground];
        cell.backgroundView = background;
        [foreground release];
        [background release];
        
        
        
        UILabel* brand = [[UILabel alloc] initWithFrame:CGRectMake(10, 
                                                                   1, 
                                                                   cell.frame.size.width-10-2, 
                                                                   cell.frame.size.height-2)];
        brand.tag = 1000;
        brand.font = [UIFont boldSystemFontOfSize:14];
        brand.textColor = [UIColor blackColor];
        brand.textAlignment = UITextAlignmentLeft;
        brand.backgroundColor = self.ratingColor;
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
    
    /*
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    */
    
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

@end


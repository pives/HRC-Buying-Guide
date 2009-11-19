//
//  FilteredCompaniesTableViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "FilteredCompaniesTableViewController.h"
#import "CompanyViewController.h"
#import "Company.h"
#import "Company+Extensions.h"
#import "UIBarButtonItem+extensions.h"


@implementation FilteredCompaniesTableViewController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize filterKey;
@synthesize filterObject;
@synthesize sortControl;


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    self.sortControl = nil;
    self.filterKey = nil;
    self.filterObject = nil;
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}

- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object{
    
    if(self = [super initWithStyle:UITableViewStylePlain]){
        
        self.managedObjectContext = context;
        self.filterKey = key;
        self.filterObject = object;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = NO;
    
    UISegmentedControl* control = [[[UISegmentedControl alloc] initWithItems:
                                   [NSArray arrayWithObjects:
                                    @"Alphabetically", 
                                    @"Rating", 
                                    nil]] autorelease];

    control.segmentedControlStyle = UISegmentedControlStyleBar;
    [control setWidth:155 forSegmentAtIndex:0];
    [control setWidth:155 forSegmentAtIndex:1];
    control.selectedSegmentIndex = 0;
    [control addTarget:self action:@selector(changeSort:) forControlEvents:UIControlEventValueChanged];

    
    NSArray* items = [NSArray arrayWithObjects:[UIBarButtonItem flexibleSpaceItem], 
                      [UIBarButtonItem itemWithView:control], 
                      [UIBarButtonItem flexibleSpaceItem],
                      nil];
    
    self.toolbarItems = items;
    
    self.sortControl = control;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    
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

- (IBAction)changeSort:(id)sender{
    
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
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //TODO: catch exception in case table is empty (but should never be)
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [managedObject valueForKey:@"name"];
    cell.detailTextLabel.text = [(Company*)managedObject ratingFormatted];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];

	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Company* selectedCompany = (Company*)[fetchedResultsController objectAtIndexPath:indexPath];
    
    CompanyViewController *detailViewController = [[CompanyViewController alloc] initWithCompany:selectedCompany 
                                                                                        category:(Category*)self.filterObject]; 
                                                                                                                      
    detailViewController.view.frame = self.view.bounds;
    //[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    //ususlly returns the last configure controller, instead we are creating a new one each time so that the segmented control works
    //this may be expensive, but we will see
    
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	//[fetchRequest setFetchBatchSize:20];
    //TODO: reenable batchsize?
	
    NSFetchedResultsController *aFetchedResultsController;
    
    if(sortControl.selectedSegmentIndex == 0){
     
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN %K", filterObject, filterKey]];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
       aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                    managedObjectContext:managedObjectContext 
                                                                                                      sectionNameKeyPath:@"name" 
                                                                                                               cacheName:@"CompaniesList"];
        
        [sortDescriptor release];
        [sortDescriptors release];
        
    }else{
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN %K", filterObject, filterKey]];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                    managedObjectContext:managedObjectContext 
                                                                                                      sectionNameKeyPath:nil
                                                                                                               cacheName:@"CompaniesList"];        
        
        [sortDescriptor release];
        [sortDescriptors release];
    }
    
    self.fetchedResultsController = aFetchedResultsController;
		
	[aFetchedResultsController release];
	[fetchRequest release];
	
	
	return fetchedResultsController;
} 



@end


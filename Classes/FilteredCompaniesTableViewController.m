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
#import "UIColor+extensions.h"
#import "KeyViewController.h"
#import "Category+Extensions.h"


@implementation FilteredCompaniesTableViewController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize filterKey;
@synthesize filterObject;
@synthesize sortControl;
@synthesize cellColors;


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    self.cellColors = nil;    
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
                                    @"Rating", 
                                    @"Alphabetically",
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
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"info2.png"] 
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self 
                                                                     action:@selector(showKey)];
    
    UILabel* tv = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    tv.text = [(Category*)filterObject nameDisplayFriendly];
    tv.textAlignment = UITextAlignmentCenter;
    tv.adjustsFontSizeToFitWidth = YES;
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont boldSystemFontOfSize:19];
    tv.shadowColor = [UIColor darkGrayColor];
    self.navigationItem.titleView = tv;
    
    //self.title = [filterObject valueForKey:@"name"];
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.cellColors = [NSArray arrayWithObjects:[UIColor gpGreen], [UIColor gpYellow], [UIColor gpRed], nil];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self changeSort:self];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    
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


- (void)showKey{
    
    KeyViewController *detailViewController = [[KeyViewController alloc] init];
    
    //[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController presentModalViewController:detailViewController animated:YES];
    [detailViewController release];
    
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


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(sortControl.selectedSegmentIndex==0){
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        UILabel* header = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, 60)];
        [headerView addSubview:header];
        
        header.textColor = [UIColor whiteColor];
        header.font = [UIFont boldSystemFontOfSize:14];
        
        if([[sectionInfo name] isEqualToString:@"0"]){
            header.text = @"Support these brands";
            headerView.backgroundColor = [UIColor gpGreenHeader];
            header.backgroundColor = [UIColor gpGreenHeader];
            
        }else if([[sectionInfo name] isEqualToString:@"1"]){
            header.text = @"Brands that could do better";
            headerView.backgroundColor = [UIColor gpYellowHeader];
            header.backgroundColor = [UIColor gpYellowHeader];
            
        }else {
            header.text = @"Avoid these brands or Non-responders";
            headerView.backgroundColor = [UIColor gpRedHeader];
            header.backgroundColor = [UIColor gpRedHeader];
        }
        
        [header release];
        return [headerView autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(sortControl.selectedSegmentIndex==0){
        
        return 60;
        
    }
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
               
        UILabel* rating = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 30, cell.frame.size.height-2)];
        rating.tag = 999;
        rating.font = [UIFont boldSystemFontOfSize:12];
        rating.textColor = [UIColor blackColor];
        rating.textAlignment = UITextAlignmentRight;
        rating.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [cell addSubview:rating];
        [rating release];
        
        UILabel* company = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 230, cell.frame.size.height-2)];
        company.tag = 1000;
        company.font = [UIFont boldSystemFontOfSize:14];
        company.textColor = [UIColor blackColor];
        company.textAlignment = UITextAlignmentLeft;
        company.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

        [cell addSubview:company];
        [company release];
        
        
        UIView* background = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView = background;
        [background release];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
	// Configure the cell.
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel* company = (UILabel*)[cell viewWithTag:1000];
    company.text = [managedObject valueForKey:@"name"];
    UILabel* rating = (UILabel*)[cell viewWithTag:999];
    rating.text = [(Company*)managedObject ratingFormatted];
    
    int cellColorValue = [[(Company*)managedObject ratingLevel] intValue];
    UIColor* cellColor = [cellColors objectAtIndex:cellColorValue];
    
    cell.backgroundView.backgroundColor = cellColor;        
    rating.backgroundColor = cellColor;
    company.backgroundColor = cellColor;
    
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
    //[self performSelector:@selector(deselectIndexPath:) withObject:indexPath afterDelay:0.25];
    

}


- (void)deselectIndexPath:(NSIndexPath*)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    
    if(sortControl.selectedSegmentIndex == 1){
     
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
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ratingLevel" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO];

        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptor2, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN %K", filterObject, filterKey]];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                    managedObjectContext:managedObjectContext 
                                                                                                      sectionNameKeyPath:@"ratingLevel"
                                                                                                               cacheName:@"CompaniesList"];        
        
        [sortDescriptor release];
        [sortDescriptor2 release];
        [sortDescriptors release];
    }
    
    self.fetchedResultsController = aFetchedResultsController;
		
	[aFetchedResultsController release];
	[fetchRequest release];
	
	
	return fetchedResultsController;
} 



@end


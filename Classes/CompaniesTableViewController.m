//
//  CompaniesTableViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//


//[self.tableView setContentOffset:CGPointMake(0,self.searchDisplayController.searchBar.frame.size.height)];

#import "CompaniesTableViewController.h"
#import "BGCompany.h"
#import "BGBrand.h"
#import "Company+Extensions.h"
#import "UIColor+extensions.h"
#import "UIView-Extensions.h"
#import "NSString+extensions.h"
#import "NSManagedObjectContext+Extensions.h"
#import "Brand+Extensions.h"

NSString *const DidSelectBrandNotification = @"DidSelectBrandNotification";

@implementation CompaniesTableViewController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize cellColors;
@synthesize searching;
@synthesize searchResultsController;


#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	self.searchResultsController = nil;
    self.cellColors = nil;    
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	
	return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
}

- (id) init
{
	self = [super initWithNibName:@"CompaniesTableViewController" bundle:nil];
	if (self != nil) {
		self.cellColors = [NSArray arrayWithObjects:[UIColor cellGreen], [UIColor cellYellow], [UIColor cellRed], nil];
	}
	return self;
}

- (void)loadView{
	
	
	[super loadView];
	
}

- (void)resignWithNotification:(NSNotification*)note{
    
    [self.searchDisplayController.searchBar resignFirstResponder];
    [self.searchDisplayController setActive:NO animated:NO];
    self.searching = NO;
    self.searchResultsController = nil;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailBG"]];
    iv.frame = self.view.bounds;
    self.tableView.backgroundView = iv;
    [iv release];
    
    
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignWithNotification:) name:UIApplicationWillResignActiveNotification object:nil];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	for(UITableViewCell* eachCell in [self.searchDisplayController.searchResultsTableView visibleCells]){		
		[eachCell setSelected:NO animated:YES];
	}
	//elf.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	//self.tableView.tableHeaderView.backgroundColor = [UIColor blueColor];
//	self.searchBar = [[UISearchBar alloc] init];
	//self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
	//self.tableView.tableHeaderView.frame = CGRectMake(0, 0, 320, 44);

	if(fetchedResultsController== nil)
		[self fetchAndReload];
}


- (void)fetchAndReload{
	
    self.fetchedResultsController = nil;
    
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[managedObjectContext resetCoreDataStore];
		[managedObjectContext displayCcoreDataError];


	}

    [self.tableView reloadData];

}




#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    NSUInteger count = [[self.fetchedResultsController sections] count];
    return (count == 0) ? 1 : count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ( [[self.fetchedResultsController sections] count] > section ) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	}
	else {
		return 0;
	}

}

//TODO: find out if client wants to see the header, to many colors in my opinion.
/*
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return @"#";
    }
    
    return [[[fetchedResultsController sections] objectAtIndex:section] name];
}
 */


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
       
        UILabel* rating = [[UILabel alloc] initWithFrame:CGRectMake(255, 0, 30, cell.frame.size.height)];
        rating.tag = 999;
        rating.font = [UIFont boldSystemFontOfSize:12];
        rating.textColor = [UIColor blackColor];
        rating.textAlignment = UITextAlignmentRight;
        rating.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [cell.contentView addSubview:rating];
        [rating release];
               
        UILabel* company = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 230, cell.frame.size.height)];
        company.tag = 1000;
        company.font = [UIFont boldSystemFontOfSize:14];
        company.textColor = [UIColor blackColor];
        company.textAlignment = UITextAlignmentLeft;
        company.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [cell.contentView addSubview:company];
        [company release];
        
        
        UIView* background = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView = background;
        [background release];
        
    }
    
	// Configure the cell.
	BGBrand* managedObject = (BGBrand*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel* brand = (UILabel*)[cell viewWithTag:1000];
    brand.text = managedObject.name;
    
    
    BOOL nonResponder = [[managedObject nonResponder] boolValue];
    
    if(nonResponder)
        [brand setFont:[UIFont italicSystemFontOfSize:14]];
    else
        [brand setFont:[UIFont boldSystemFontOfSize:14]];
    
   
    UILabel* rating = (UILabel*)[cell viewWithTag:999];
    rating.text = [managedObject ratingFormatted];
   
    if(nonResponder)
        [rating setFont:[UIFont italicSystemFontOfSize:14]];
    else
        [rating setFont:[UIFont boldSystemFontOfSize:14]];
    
    
    int cellColorValue = [[managedObject ratingLevel] intValue];
    UIColor* cellColor = [cellColors objectAtIndex:cellColorValue];
    
    cell.backgroundView.backgroundColor = cellColor;        
    rating.backgroundColor = cellColor;
    brand.backgroundColor = cellColor;
        
    if([managedObject.partner boolValue]){
        
        cell.imageView.image = [UIImage imageNamed:@"HRC_Icon.png"];
        [brand setFrame:CGRectMake(30, 0, 230-20, cell.frame.size.height)];
        
    }else{
        
        cell.imageView.image = nil;
        [brand setFrame:CGRectMake(10, 0, 230, cell.frame.size.height)];

    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BGBrand* selectedBrand = (BGBrand*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectBrandNotification object:selectedBrand]; 
    
    //[self performSelector:@selector(deselectIndexPath:) withObject:indexPath afterDelay:0.25];
    
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark sectionIndexTitlesForTableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
    if(fetchedResultsController==nil)
        return nil;
        
	 NSMutableArray* array = [[self.fetchedResultsController sectionIndexTitles] mutableCopy];
	[array insertObject:UITableViewIndexSearch atIndex:0];
	
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    return [array autorelease];
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if(fetchedResultsController==nil)
        return 0;
           
	int newIndex = index;

	if(index != 0)
		newIndex -= 1;
	else{
		[self.tableView scrollRectToVisible:self.tableView.tableHeaderView.bounds animated:NO];
		return -1;
	} 
	
    // tell table which section corresponds to section title/index (e.g. "B",1))
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:newIndex];
}



#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
	if(searching)
		return searchResultsController;
	
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
     */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //NSNumber *yesNumber = [NSNumber numberWithBool:YES];

    //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"includeInIndex == %@", yesNumber]];

	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BGBrand" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"namefirstLetter" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted" ascending:YES selector:@selector(caseInsensitiveCompare:)];

	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:@"namefirstLetter" 
                                                                                                           cacheName:nil];
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
    [sortDescriptor2 release];
	[sortDescriptors release];
	
	return fetchedResultsController;
} 


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods



- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)aTableView{
	
	FJSLog(@"did load tv");

}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)aTableView{
	
	FJSLog(@"will show tv");
	
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)aTableView{
	
	FJSLog(@"did show tv");
	
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)aTableView{
	
	

}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)aTableView{
	
}




- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
	
	NSLog(@"will begin search");

	self.searching = YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
	
	NSLog(@"did begin search");

}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	/*
	 Set up the fetched results controller.
     */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BGBrand" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"namefirstLetter" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"nameSortFormatted contains[c] %@", searchString];
	[fetchRequest setPredicate:predicate];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:nil];
	self.searchResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
    [sortDescriptor2 release];
	[sortDescriptors release];
	
    [self.searchResultsController performFetch:nil];
    
	// Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
	
	
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
	
	self.searching = NO;
}




#pragma mark -
#pragma mark UISearchBar Delegate Methods

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar{
		

	
}

- (BOOL)earchBarShouldBeginEditing:(UISearchBar *)searchBar{
	
	NSLog(@"will begin editing");
	
	return YES;
	
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	
	NSLog(@"Began editing");
	
}

@end


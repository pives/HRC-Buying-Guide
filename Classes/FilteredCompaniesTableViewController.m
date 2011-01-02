//
//  FilteredCompaniesTableViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "FilteredCompaniesTableViewController.h"
#import "BGCompany.h"
#import "Company+Extensions.h"
#import "UIColor+extensions.h"
#import "BGBrand.h"
#import "NSString+extensions.h"
#import "UIView-Extensions.h"
#import "NSManagedObjectContext+Extensions.h"
#import "Brand+Extensions.h"

NSString *const DidSelectFilteredCompanyNotification = @"didSelectFilteredCompany";
NSString *const FilteredCompanySearchBegan = @"FilteredSearchBegan";
NSString *const FilteredCompanySearchEnded = @"FilteredSearchEnded";;

@implementation FilteredCompaniesTableViewController

@synthesize managedObjectContext;
@synthesize filterKey;
@synthesize filterObject;
@synthesize cellColors;
@synthesize mode;
@synthesize searchResultsController;
@synthesize searching;
@synthesize ratingFetchedResultsController;
@synthesize nameFetchedResultsController;



#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.ratingFetchedResultsController = nil;
	self.nameFetchedResultsController = nil;	
	self.searchResultsController = nil;
    self.cellColors = nil;    
    self.filterKey = nil;
    self.filterObject = nil;
	[managedObjectContext release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}

- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object{
    
    if(self = [super initWithNibName:@"CompaniesTableViewController" bundle:nil]){
        
        self.managedObjectContext = context;
        self.filterKey = key;
        self.filterObject = object;
        self.mode = FilterdTableViewControllerModeRating;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
        
    //self.title = [filterObject valueForKey:@"name"];
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.cellColors = [NSArray arrayWithObjects:[UIColor cellGreen], [UIColor cellYellow], [UIColor cellRed], nil];
    //self.tableView.showsVerticalScrollIndicator = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
	
	for(UITableViewCell* eachCell in [self.searchDisplayController.searchResultsTableView visibleCells]){		
		[eachCell setSelected:NO animated:YES];
	}
	
    //[self.view setSizeHeight:self.view.frame.size.height-44];
    
}

- (void)fetch{
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[managedObjectContext resetCoreDataStore];
		[managedObjectContext displayCcoreDataError];

	}
}

- (void)reload{
	
	[self.tableView reloadData];
	
	//[self.tableView scrollRectToVisible:self.tableView.tableHeaderView.bounds animated:NO];

	/*
	if([[self.fetchedResultsController sections] count]>0)
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

	    //TODO: catch exception in case table is empty (but should never be)
	*/
}


//TODO: possiblt rework this to scroll to the bottom of the nearest section if the actual section doesn't exist
//currently scrolls to the top of the neares section

- (NSIndexPath*)sectionIndexOfRedSection{
    
    int sections = [self numberOfSectionsInTableView:self.tableView];
    
    int index = sections-1;
    
    return [NSIndexPath indexPathForRow:0 inSection:index];
    
}

- (NSIndexPath*)sectionIndexOfYellowSection{
    
    int sections = [self numberOfSectionsInTableView:self.tableView];
    
    int index = -1;

    if(sections == 3)
        index = 1;
    else if (sections == 1)
        index = 0;
        
    if(index == -1){
        for(int i = 0; i < (sections); i++){
            
            id data = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            index = i;
            if([[(BGBrand*)data ratingLevel] intValue] >= 1){
                break;
            }
        }
    }
        
    
    return [NSIndexPath indexPathForRow:0 inSection:index];
}

- (NSIndexPath*)sectionIndexOfGreenSection{
    
    return [NSIndexPath indexPathForRow:0 inSection:0];
}



#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[self.fetchedResultsController sections] count];
    return (count == 0) ? 1 : count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if([[self.fetchedResultsController sections] count]==0)
		return 0;
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
	if(searching)
		return nil;
	
    if(mode == FilterdTableViewControllerModeRating){
		
		if([[self.fetchedResultsController sections] count]==0)
			return nil;
		
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        UILabel* header = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, 60)];
        [headerView addSubview:header];
        
        header.textColor = [UIColor whiteColor];
        header.font = [UIFont boldSystemFontOfSize:14];
        
        if([[sectionInfo name] isEqualToString:@"0"]){
            header.text = @"Highest workplace equality scores";
            headerView.backgroundColor = [UIColor headerGreen];
            header.backgroundColor = [UIColor headerGreen];
            
        }else if([[sectionInfo name] isEqualToString:@"1"]){
            header.text = @"Moderate workplace equality scores";
            headerView.backgroundColor = [UIColor headerYellow];
            header.backgroundColor = [UIColor headerYellow];
            
        }else {
            header.text = @"Lowest workplace equality scores";
            headerView.backgroundColor = [UIColor headerRed];
            header.backgroundColor = [UIColor headerRed];
        }
        
        [header release];
        return [headerView autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
	if(searching)
		return 0;
	
	/*
	if(tableView == self.searchDisplayController.searchResultsTableView)
		return 0;
	*/				
	
    if(mode == FilterdTableViewControllerModeRating)
        return 60;
    
    return 0;
}

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
	BGBrand *managedObject = (BGBrand*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel* brand = (UILabel*)[cell viewWithTag:1000];
    brand.text = managedObject.name;
    
    BOOL nonResponder = [[managedObject nonResponder] boolValue];
    
    if(nonResponder)
        [brand setFont:[UIFont italicSystemFontOfSize:14]];
    else
        [brand setFont:[UIFont boldSystemFontOfSize:14]];
    
   
    UILabel* rating = (UILabel*)[cell viewWithTag:999];
    rating.text = [managedObject  ratingFormatted];
    
    if(nonResponder)
        [rating setFont:[UIFont italicSystemFontOfSize:14]];
    else
        [rating setFont:[UIFont boldSystemFontOfSize:14]];
    
    
    int cellColorValue = [[managedObject ratingLevel] intValue];
    UIColor* cellColor = [cellColors objectAtIndex:cellColorValue];
    
    cell.backgroundView.backgroundColor = cellColor;        
    rating.backgroundColor = cellColor;
    brand.backgroundColor = cellColor;
    /*
    if(mode == FilterdTableViewControllerModeRating){
        [rating setFrame:CGRectMake(278, 0, 30, cell.frame.size.height)];
    }else{
        [rating setFrame:CGRectMake(255, 0, 30, cell.frame.size.height)];
    }
    */
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
    
    
    BGCompany* selectedCompany = (BGCompany*)[[(BGBrand*)[self.fetchedResultsController objectAtIndexPath:indexPath] companies] anyObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectFilteredCompanyNotification object:selectedCompany];
	
}

#pragma mark -
#pragma mark sectionIndexTitlesForTableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
    if(self.fetchedResultsController==nil)
        return nil;
    if(mode == FilterdTableViewControllerModeRating)
        return nil;
    
	
    NSMutableArray* array = [[self.fetchedResultsController sectionIndexTitles] mutableCopy];
	[array insertObject:UITableViewIndexSearch atIndex:0];
	
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    return [array autorelease];
	
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if(self.fetchedResultsController==nil)
        return 0;
    if(mode == FilterdTableViewControllerModeRating)
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
	
	NSNumber *yesNumber = [NSNumber numberWithBool:YES];
	NSString *predicateString = @"(%@ IN %K)&&(includeInIndex == %@)";
	
	if(mode == FilterdTableViewControllerModeAlphabetically){

		if(nameFetchedResultsController==nil){
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			// Edit the entity name as appropriate.
			
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"BGBrand" inManagedObjectContext:managedObjectContext];
			[fetchRequest setEntity:entity];
			
			// Set the batch size to a suitable number.
			[fetchRequest setFetchBatchSize:20];
			
			NSFetchedResultsController *aFetchedResultsController;
			
			
			// Edit the sort key as appropriate.
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
										[[[NSSortDescriptor alloc] initWithKey:@"namefirstLetter" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
										[[[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
										nil];
			
			[fetchRequest setSortDescriptors:sortDescriptors];
			
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateString, filterObject, filterKey, yesNumber]];
			
			// Edit the section name key path and cache name if appropriate.
			// nil for section name key path means "no sections".
			aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																			managedObjectContext:managedObjectContext 
																			  sectionNameKeyPath:@"namefirstLetter" 
																					   cacheName:nil];
			
			[sortDescriptors release];
			[fetchRequest release];
			
			
			self.nameFetchedResultsController = aFetchedResultsController;
			[aFetchedResultsController release];
			
		}
		
		return nameFetchedResultsController;
		
    }else{
        
		if(ratingFetchedResultsController == nil){
			
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			// Edit the entity name as appropriate.
			
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"BGBrand" inManagedObjectContext:managedObjectContext];
			[fetchRequest setEntity:entity];
			
			// Set the batch size to a suitable number.
			//[fetchRequest setFetchBatchSize:20];
			//TODO: reenable batchsize?
			
			NSFetchedResultsController *aFetchedResultsController;
			
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: 
										[[[NSSortDescriptor alloc] initWithKey:@"ratingLevel" ascending:YES] autorelease],
										[[[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO] autorelease],
										[[[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted"  ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
										nil];
			
			[fetchRequest setSortDescriptors:sortDescriptors];
			
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateString, filterObject, filterKey, yesNumber]];
			
			// Edit the section name key path and cache name if appropriate.
			// nil for section name key path means "no sections".
			aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																			managedObjectContext:managedObjectContext 
																			  sectionNameKeyPath:@"ratingLevel"
																					   cacheName:nil];        
			
			[sortDescriptors release];
			[fetchRequest release];
			
			self.ratingFetchedResultsController = aFetchedResultsController;
			[aFetchedResultsController release];
			
		}
		
		return ratingFetchedResultsController;
    }
    		
	
	
	return nil;
} 

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
		
	self.searching = YES;
	//[controller.searchResultsTableView scrollRectToVisible:self.tableView.tableHeaderView.bounds animated:NO];

	[[NSNotificationCenter defaultCenter] postNotificationName:FilteredCompanySearchBegan object:self];

}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
	
	//[controller.searchResultsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
	
	self.searching = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:FilteredCompanySearchEnded object:self];
	[self.tableView reloadData];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	
	if(mode == FilterdTableViewControllerModeAlphabetically){
		
		self.searchResultsController = [self alphabeticalSearchResultsControllerForString:searchString];
		
	}else{
		
		self.searchResultsController = [self ratingSearchResultsControllerForString:searchString];

	}
	
	
	[self fetch];
	// Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (NSFetchedResultsController*)alphabeticalSearchResultsControllerForString:(NSString*)searchString{
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BGBrand" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
    NSFetchedResultsController *aFetchedResultsController;
	
	// Edit the sort key as appropriate.
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
								[[[NSSortDescriptor alloc] initWithKey:@"namefirstLetter" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
								[[[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
								nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
		
	NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"%@ IN %K", filterObject, filterKey];
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"nameSortFormatted contains[c] %@", searchString];
	
	NSArray* predicates = [NSArray arrayWithObjects:
						   filterPredicate,
						   predicate,
						   nil];
	
	NSCompoundPredicate* andPredicate = [[[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates] autorelease];
	[fetchRequest setPredicate:andPredicate];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																	managedObjectContext:managedObjectContext 
																	  sectionNameKeyPath:nil 
																			   cacheName:nil];
	
	[sortDescriptors release];
	[fetchRequest release];
	
	
	return [aFetchedResultsController autorelease];
	
}

- (NSFetchedResultsController*)ratingSearchResultsControllerForString:(NSString*)searchString{
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BGBrand" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
    NSFetchedResultsController *aFetchedResultsController;
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: 
								[[[NSSortDescriptor alloc] initWithKey:@"ratingLevel" ascending:YES] autorelease],
								[[[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO] autorelease],
								[[[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted"  ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
								nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
		
	NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"%@ IN %K", filterObject, filterKey];
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"nameSortFormatted contains[c] %@", searchString];
	NSArray* predicates = [NSArray arrayWithObjects:
						   filterPredicate,
						   predicate,
						   nil];
	
	NSCompoundPredicate* andPredicate = [[[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates] autorelease];
	[fetchRequest setPredicate:andPredicate];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																	managedObjectContext:managedObjectContext 
																	  sectionNameKeyPath:nil
																			   cacheName:nil];        
	
	[sortDescriptors release];
	[fetchRequest release];
	
	
	return [aFetchedResultsController autorelease];
}



@end


//
//  CompaniesTableViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "CompaniesTableViewController.h"
#import "Company.h"
#import "Company+Extensions.h"
#import "UIColor+extensions.h"
#import "UIView-Extensions.h"

NSString *const DidSelectCompanyNotification = @"CompanySelected";

@implementation CompaniesTableViewController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize cellColors;

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    self.cellColors = nil;    
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.cellColors = [NSArray arrayWithObjects:[UIColor gpGreen], [UIColor gpYellow], [UIColor gpRed], nil];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
        [cell addSubview:rating];
        [rating release];
        
        UILabel* company = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 230, cell.frame.size.height)];
        company.tag = 1000;
        company.font = [UIFont boldSystemFontOfSize:14];
        company.textColor = [UIColor blackColor];
        company.textAlignment = UITextAlignmentLeft;
        [cell addSubview:company];
        [company release];
        
        
        UIView* background = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView = background;
        [background release];
        
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
       
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
#ifdef DEBUG = 1
    Company* selectedCompany = (Company*)[fetchedResultsController objectAtIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectCompanyNotification object:selectedCompany]; 
    
#else
    [self performSelector:@selector(deselectIndexPath:) withObject:indexPath afterDelay:0.25];
    
#endif
}

- (void)deselectIndexPath:(NSIndexPath*)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark sectionIndexTitlesForTableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
    if(fetchedResultsController==nil)
        return nil;
        
    NSMutableArray* titles = [[fetchedResultsController sectionIndexTitles] mutableCopy];
    [titles replaceObjectAtIndex:0 withObject:@"#"];    
    
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    
    return titles;
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if(fetchedResultsController==nil)
        return 0;
    
    if([title isEqualToString:@"#"])
        title = @"3";
        
    // tell table which section corresponds to section title/index (e.g. "B",1))
    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"namefirstLetter" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];

	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:@"namefirstLetter" 
                                                                                                           cacheName:@"CompaniesList"];
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
    [sortDescriptor2 release];
	[sortDescriptors release];
	
	return fetchedResultsController;
} 


@end


//
//  HRCCompaniesResultsController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/22/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "HRCCompaniesResultsController.h"
#import "BGCategory.h"
#import "NSManagedObjectContext+Extensions.h"
#import "BGBrand.h"
#import "Brand+Extensions.h"
#import "UIColor+extensions.h"

@implementation HRCCompaniesResultsController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize cellColors;
@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize searchResultsController;

#pragma mark -
#pragma mark Memory management


- (void)dealloc {
	self.searchResultsController = nil;
	self.savedSearchTerm = nil;	
    self.cellColors = nil;    
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.cellColors = [NSArray arrayWithObjects:[UIColor cellGreen], [UIColor cellYellow], [UIColor cellRed], nil];


	}
	return self;
}


- (void)fetch{
	
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
    
    static NSString *CellIdentifier = @"CompanyCell";
    
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
	BGBrand* managedObject = (BGBrand*)[fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel* brand = (UILabel*)[cell viewWithTag:1000];
    brand.text = managedObject.name;
    UILabel* rating = (UILabel*)[cell viewWithTag:999];
    rating.text = [managedObject ratingFormatted];
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Company* selectedCompany = (Company*)[[(Brand*)[fetchedResultsController objectAtIndexPath:indexPath] companies] anyObject];
    //[[NSNotificationCenter defaultCenter] postNotificationName:DidSelectCompanyNotification object:selectedCompany]; 
	
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark sectionIndexTitlesForTableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
    if(self.fetchedResultsController==nil)
        return nil;
	
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    
    return [fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if(self.fetchedResultsController==nil)
        return 0;
	
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



@end

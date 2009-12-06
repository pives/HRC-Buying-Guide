//
//  FilteredCompaniesTableViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "FilteredCompaniesTableViewController.h"
#import "Company.h"
#import "Company+Extensions.h"
#import "UIColor+extensions.h"
#import "Category+Extensions.h"
#import "Brand.h"
#import "NSString+extensions.h"
#import "UIView-Extensions.h"

NSString *const DidSelectFilteredCompanyNotification = @"didSelectFilteredCompany";

@implementation FilteredCompaniesTableViewController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize filterKey;
@synthesize filterObject;
@synthesize cellColors;
@synthesize mode;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.cellColors = nil;    
    self.filterKey = nil;
    self.filterObject = nil;
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}

- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object{
    
    if(self = [super initWithStyle:UITableViewStylePlain]){
        
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
    self.cellColors = [NSArray arrayWithObjects:[UIColor gpGreen], [UIColor gpYellow], [UIColor gpRed], nil];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    //[self.view setSizeHeight:self.view.frame.size.height-44];
    
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
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //TODO: catch exception in case table is empty (but should never be)
    
    
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
            
            id data = [fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            index = i;
            if([[(Brand*)data company].ratingLevel intValue] >= 1){
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
    NSUInteger count = [[fetchedResultsController sections] count];
    return (count == 0) ? 1 : count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(mode == FilterdTableViewControllerModeRating){
        
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
            header.text = @"Avoid these brands or non-responders";
            headerView.backgroundColor = [UIColor gpRedHeader];
            header.backgroundColor = [UIColor gpRedHeader];
        }
        
        [header release];
        return [headerView autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(mode == FilterdTableViewControllerModeRating){
        
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
	Brand *managedObject = (Brand*)[fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel* brand = (UILabel*)[cell viewWithTag:1000];
    brand.text = managedObject.name;
    UILabel* rating = (UILabel*)[cell viewWithTag:999];
    rating.text = [managedObject.company ratingFormatted];
    
    int cellColorValue = [[managedObject.company ratingLevel] intValue];
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
    if([[managedObject company].partner boolValue]){
        
        cell.imageView.image = [UIImage imageNamed:@"HRC_Icon.png"];
        [brand setFrame:CGRectMake(30, 0, 230-20, cell.frame.size.height)];
        
    }else{
        
        cell.imageView.image = nil;
        [brand setFrame:CGRectMake(10, 0, 230, cell.frame.size.height)];
        
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Company* selectedCompany = (Company*)[(Brand*)[fetchedResultsController objectAtIndexPath:indexPath] company];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectFilteredCompanyNotification object:selectedCompany];
     

}


- (void)deselectIndexPath:(NSIndexPath*)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark -
#pragma mark sectionIndexTitlesForTableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
    if(fetchedResultsController==nil)
        return nil;
    if(mode == FilterdTableViewControllerModeRating)
        return nil;
    
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    
    return [fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if(fetchedResultsController==nil)
        return 0;
    if(mode == FilterdTableViewControllerModeRating)
        return 0;

    
    // tell table which section corresponds to section title/index (e.g. "B",1))
    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}






#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    //ususlly returns the last configure controller, instead we are creating a new one each time so that the segmented control works
    //this may be expensive, but we will see
    /*
    if (lastMode == mode) {
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
	//[fetchRequest setFetchBatchSize:20];
    //TODO: reenable batchsize?
	
    NSFetchedResultsController *aFetchedResultsController;
    
    if(mode == FilterdTableViewControllerModeAlphabetically){
     
        // Edit the sort key as appropriate.
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
                                    [[[NSSortDescriptor alloc] initWithKey:@"namefirstLetter" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
                                    [[[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
                                    nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN %K", filterObject, filterKey]];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
       aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                    managedObjectContext:managedObjectContext 
                                                                                                      sectionNameKeyPath:@"namefirstLetter" 
                                                                                                               cacheName:@"CompaniesList"];
        
        [sortDescriptors release];
        
    }else{
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: 
                                    [[[NSSortDescriptor alloc] initWithKey:@"company.ratingLevel" ascending:YES] autorelease],
                                    [[[NSSortDescriptor alloc] initWithKey:@"company.rating" ascending:NO] autorelease],
                                    [[[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted"  ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
                                    nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN %K", filterObject, filterKey]];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                    managedObjectContext:managedObjectContext 
                                                                                                      sectionNameKeyPath:@"company.ratingLevel"
                                                                                                               cacheName:@"CompaniesList"];        
        
        [sortDescriptors release];
    }
    
    self.fetchedResultsController = aFetchedResultsController;
		
	[aFetchedResultsController release];
	[fetchRequest release];
	
	
	return fetchedResultsController;
} 



@end


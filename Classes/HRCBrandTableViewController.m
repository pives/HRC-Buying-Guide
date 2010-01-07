//
//  PageTableViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/24/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "HRCBrandTableViewController.h"
#import "Company.h"
#import "Category.h"
#import "UIColor+extensions.h"
#import "Brand.h"
#import "NSManagedObjectContext+Extensions.h"
#import "FilteredCompaniesViewController.h"

NSString *const BrandsTableCategoryButtonTouchedNotification = @"BrandsTableCategory";

@implementation HRCBrandTableViewController

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
        
		[self setCompany:aCompany category:aCategory color:aColor];
        
    }
    return self;
}

- (void)setCompany:(Company*)aCompany category:(Category*)aCategory color:(UIColor*)aColor{
	
	self.company = aCompany;
	self.managedObjectContext = company.managedObjectContext;
	self.category = aCategory;
	self.ratingColor = aColor;
	
}


- (void)setTableFrame:(CGRect)aFrame{
    
    tableFrame = aFrame;
    [self.view setFrame:tableFrame];
    [self.tableView setFrame:tableFrame];
    
}

- (void)loadView{
    
    self.view = [[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 40;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //self.tableView.separatorColor = [UIColor whiteColor];
    //self.view.backgroundColor = [UIColor reallyLightGray];
    self.view.backgroundColor = [UIColor clearColor];

	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"Show Other Brands in Category" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(showOtherBrandsCategory:) forControlEvents:UIControlEventTouchUpInside];
	[button setFrame:CGRectMake(10, 10, tableFrame.size.width-20, 45)];
	
	UIView* footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableFrame.size.width, 65)];
	[footer addSubview:button];
	
	self.tableView.tableFooterView = footer;
    
}

- (void)showOtherBrandsCategory:(id)sender{
	
    [[NSNotificationCenter defaultCenter] postNotificationName:BrandsTableCategoryButtonTouchedNotification 
														object:self.category];   
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
	[self fetch];
	//when switching tableviews IF the brand table is empty (company name is in the cat but no brand)
    if((self.tableView != nil) && 
	   ([self.tableView numberOfSections] > 0) && 
	   ([self.tableView numberOfRowsInSection:0] > 0))
       [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
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
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        //cell.backgroundView.backgroundColor = self.ratingColor;
        //cell.textLabel.backgroundColor = [UIColor clearColor];
        //cell.contentView.backgroundColor = self.ratingColor;
        
        //TODO: fix cell outlines
        /*
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
        */
        
        /*
        UILabel* brand = [[UILabel alloc] initWithFrame:CGRectMake(10, 
                                                                   1, 
                                                                   100, 
                                                                   40)];
        brand.tag = 1000;
        brand.font = [UIFont boldSystemFontOfSize:14];
        brand.textColor = [UIColor blackColor];
        brand.textAlignment = UITextAlignmentLeft;
        brand.backgroundColor = [UIColor clearColor];
        [cell addSubview:brand];
        [brand release];
        */
    }
    
    // Configure the cell.
    
	Brand *managedObject = (Brand*)[fetchedResultsController objectAtIndexPath:indexPath];
    
    /*
    UILabel* brand = (UILabel*)[cell viewWithTag:1000];    
	brand.text = [managedObject valueForKey:@"name"];
    */
    cell.textLabel.text = [managedObject valueForKey:@"name"];
    
    if(!([self.company.partner boolValue])){
        
        if([managedObject.partner boolValue]){
            
            cell.imageView.image = [UIImage imageNamed:@"HRC_Icon.png"];
            //[brand setFrame:CGRectMake(30, 0, 230-20, cell.frame.size.height)];
            
        }else{
            
            cell.imageView.image = nil;
            //[brand setFrame:CGRectMake(10, 0, 230, cell.frame.size.height)];
            
        }
        
    }
    
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
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nameSortFormatted" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    if(category==nil)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ IN companies", self.company]];
    else 
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%@ IN companies) AND (%@ IN categories)", self.company, self.category]];
    
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


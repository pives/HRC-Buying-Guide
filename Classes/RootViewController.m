//
//  RootViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/21/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "RootViewController.h"
#import "HRCCompaniesResultsController.h"
#import "UIBarButtonItem+extensions.h"
#import "KeyViewController.h"
#import "BGCategory.h"
#import "FilteredCompaniesViewController.h"
#import "BrandViewController.h"
//#import "NSObjectHelper.h"
#import "UIView-Extensions.h"

@implementation RootViewController

@synthesize managedObjectContext;
@synthesize cellColors;
@synthesize searchResultsController;
@synthesize companiesResultsController;
@synthesize categoriesResultsController;
@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize mode;
@synthesize modeSwitch;


- (void)dealloc {
	
	self.companiesResultsController = nil;
	self.categoriesResultsController = nil;	
	self.managedObjectContext = nil;
	self.cellColors = nil;
	self.searchResultsController = nil;
	self.savedSearchTerm = nil;
	
	
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}




/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	/*
	 [[NSNotificationCenter defaultCenter] removeObserver:self 
	 name:DidSelectCategoryNotification 
	 object:nil];
	 
	 [[NSNotificationCenter defaultCenter] removeObserver:self 
	 name:DidSelectCompanyNotification 
	 object:nil];
	 */
}

 


- (void)viewDidLoad {
    [super viewDidLoad];

	NSArray* items = [NSArray arrayWithObjects:[UIBarButtonItem flexibleSpaceItem], 
                      [UIBarButtonItem itemWithView:modeSwitch], 
                      [UIBarButtonItem flexibleSpaceItem],
                      nil];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = items;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"info2small.png"] 
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self 
                                                                     action:@selector(showKey)];
    
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:@"Donate" 
																	 style:UIBarButtonItemStyleBordered 
																	target:self 
																	action:@selector(ShowDonationMessage)];
    	
	UILabel* tv = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    tv.text = @"Buyer's Guide";
    tv.textAlignment = UITextAlignmentCenter;
    tv.adjustsFontSizeToFitWidth = YES;
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont boldSystemFontOfSize:19];
    tv.shadowColor = [UIColor darkGrayColor];
    self.navigationItem.titleView = tv;
	
	[self.tableView setSizeHeight:416-44-36];
	self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;


}



- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
	self.modeSwitch.selectedSegmentIndex = 1;
    [self toggleViews:modeSwitch];
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
    
	/*
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(categorySelectedWithNotification:) 
                                                 name:DidSelectCategoryNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(companySelectedWithNotification:) 
                                                 name:DidSelectCompanyNotification 
                                               object:nil];
    
    
	*/
	[self preloadAllBrandsFetchedResultsController];
}

#pragma mark -
#pragma mark BrandsFetchedResultsController

- (void)preloadAllBrandsFetchedResultsController{
    
	self.companiesResultsController;
} 




-(void)toggleViews:(id)sender{
    
	mode = [(UISegmentedControl*)sender selectedSegmentIndex];
	
	if(mode == HRCTableViewModeCategories){
		
		 [self.categoriesResultsController fetch];
		
	}else if(mode == HRCTableViewModeCompanies){
		
		[self.companiesResultsController fetch];
		
	}else {
		
		[self.searchResultsController fetch];
	}
	
	[self.tableView reloadData];
}

- (void)showKey{
    
    KeyViewController *detailViewController = [[KeyViewController alloc] init];
    
    //[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController presentModalViewController:detailViewController animated:YES];
    [detailViewController release];
    
}


#pragma mark -
#pragma mark Donation


- (void)ShowDonationMessage{
    
    //Unapproved UI for in app donations
    //DonationViewController *donationViewController = [[[DonationViewController alloc] initWithNibName:@"DonateView" bundle:[NSBundle mainBundle]] autorelease];
    //[self.navigationController pushViewController:donationViewController animated:YES];
    
    //NSLog(@"donated");
    
    NSString* donationText = @"Thank you for your help! This application will now close and Safari will open. All contributions are sent directly to the Human Rights Campaign and are not related to or endorsed by Apple, iTunes, or the App Store.";
    
    UIAlertView* message = [[[UIAlertView alloc] initWithTitle:@"Donate"
                                                      message:donationText 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                            otherButtonTitles:@"Donate", nil] autorelease];
    [message show];
    
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==0){
        
        //do nothing
        
    } else if(buttonIndex==1){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"DonationURL"]]];
        
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==0){
        
        //do nothing
        
    } else if(buttonIndex==1){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"DonationURL"]]];
        
    }
    
}

#pragma mark -
#pragma mark Cell Selection Notifications

- (void)categorySelectedWithNotification:(NSNotification*)note{
    
    // Navigation logic may go here -- for example, create and push another view controller.
    BGCategory* selectedCat = (BGCategory*)[note object];
    FilteredCompaniesViewController *detailViewController = [[FilteredCompaniesViewController alloc] initWithContext:self.managedObjectContext 
                                                                                                  filteredOnCategory:selectedCat
                                                                                                   filteredOnCompany:nil];
    detailViewController.view.frame = self.view.bounds;
    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}

//- (void)companySelectedWithNotification:(NSNotification*)note{
//    
//    // Navigation logic may go here -- for example, create and push another view controller.
//    BGCompany* selectedCompany = (BGCompany*)[note object];
//    
//    BrandViewController *detailViewController = [[BrandViewController alloc] initWithCompany:selectedCompany 
//                                                                                        category:nil]; 
//    
//    detailViewController.view.frame = self.view.bounds;
//    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
//    [self.navigationController pushViewController:detailViewController animated:YES];
//    [detailViewController release];
//    
//    
//}

#pragma mark -
#pragma mark Accessors

//=========================================================== 
//  searchResultsController 
//=========================================================== 
- (HRCSearchResultsController *)searchResultsController
{
	
	if(searchResultsController == nil){
		
		searchResultsController = [[HRCSearchResultsController alloc] init];
		searchResultsController.managedObjectContext = self.managedObjectContext;
	}
	
    return searchResultsController; 
}

//=========================================================== 
//  companiesResultsController 
//=========================================================== 
- (HRCCompaniesResultsController *)companiesResultsController
{
	
	if(companiesResultsController == nil){
		
		companiesResultsController = [[HRCCompaniesResultsController alloc] init];
		companiesResultsController.managedObjectContext = self.managedObjectContext;

	}
	
    return companiesResultsController; 
}

//=========================================================== 
//  categoriesResultsController 
//=========================================================== 
- (HRCCategoriesResultsController *)categoriesResultsController
{
	if(categoriesResultsController == nil){
		
		categoriesResultsController = [[HRCCategoriesResultsController alloc] init];
		categoriesResultsController.managedObjectContext = self.managedObjectContext;

	}
	
    return categoriesResultsController; 
	
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	NSInteger sections = 0;
	
	if(mode == HRCTableViewModeCategories){
		
		sections = [self.categoriesResultsController numberOfSectionsInTableView:tableView];
		
	}else if(mode == HRCTableViewModeCompanies){
		
		sections = [self.companiesResultsController numberOfSectionsInTableView:tableView];
		
	}else {
		
		sections = [self.searchResultsController numberOfSectionsInTableView:tableView];
	}

	
    return sections;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger rows = 0;

	if(mode == HRCTableViewModeCategories){
		
		rows = [self.categoriesResultsController tableView:tableView numberOfRowsInSection:section];
		
	}else if(mode == HRCTableViewModeCompanies){
		
		rows = [self.companiesResultsController tableView:tableView numberOfRowsInSection:section];

	}else {
		
		rows = [self.searchResultsController tableView:tableView numberOfRowsInSection:section];

	}
	
    return rows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell* cell = nil;
	
	if(mode == HRCTableViewModeCategories){
		
		cell = [self.categoriesResultsController tableView:tableView cellForRowAtIndexPath:indexPath];
		
	}else if(mode == HRCTableViewModeCompanies){
		
		cell = [self.companiesResultsController tableView:tableView cellForRowAtIndexPath:indexPath];

	}else {
		
		cell = [self.searchResultsController tableView:tableView cellForRowAtIndexPath:indexPath];

	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(mode == HRCTableViewModeCategories){
		
		[self.categoriesResultsController tableView:tableView didSelectRowAtIndexPath:indexPath];
		
	}else if(mode == HRCTableViewModeCompanies){
		
		[self.companiesResultsController tableView:tableView didSelectRowAtIndexPath:indexPath];

	}else {
		
		[self.searchResultsController tableView:tableView didSelectRowAtIndexPath:indexPath];

	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark sectionIndexTitlesForTableView

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
	
	NSArray* titles = nil;
    
	if(mode == HRCTableViewModeCategories){
		
		[self.categoriesResultsController performIfRespondsToSelector:@selector(sectionIndexTitlesForTableView:) withObject:table];
		
	}else if(mode == HRCTableViewModeCompanies){
		
		[self.companiesResultsController performIfRespondsToSelector:@selector(sectionIndexTitlesForTableView:) withObject:table];
		
	}else {
		
		[self.searchResultsController performIfRespondsToSelector:@selector(sectionIndexTitlesForTableView:) withObject:table];

		
	}
	
	return titles;
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
	NSInteger section = 0;
    
	if(mode == HRCTableViewModeCategories){
				
		//[self.categoriesResultsController sectionForSectionIndexTitle:title atIndex:index];
		
	}else if(mode == HRCTableViewModeCompanies){
		
		[self.companiesResultsController sectionForSectionIndexTitle:title atIndex:index];	
	}else {
		
		//[self.searchResultsController sectionForSectionIndexTitle:title atIndex:index];
		
	}
	
	return section;
}
*/




@end


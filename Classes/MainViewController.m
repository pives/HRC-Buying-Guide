//
//  MainViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "MainViewController.h"
#import "CategoriesTableViewController.h"
#import "CompaniesTableViewController.h"
#import "UIBarButtonItem+extensions.h"
#import "BGCategory.h"
#import "BGCompany.h"
#import "FilteredCompaniesViewController.h"
#import "BrandViewController.h"
#import "UIView-Extensions.h"
#import "KeyViewController.h"
#import "UIBarButtonItem+extensions.h"

@implementation MainViewController

@synthesize categoryView;
@synthesize modeSwitch;
@synthesize managedObjectContext;
@synthesize companyView;
@synthesize brandController;


- (void)dealloc {
	self.brandController = nil;
    self.companyView = nil;
    self.categoryView = nil;
    [super dealloc];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
}



- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DidSelectCategoryNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DidSelectBrandNotification 
                                                  object:nil];
    
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"info2small.png"] 
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self 
                                                                     action:@selector(showKey)];
    
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:@"Donate" 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(ShowDonationMessage)];

    
    NSArray* items = [NSArray arrayWithObjects:[UIBarButtonItem flexibleSpaceItem],
                      [UIBarButtonItem itemWithView:modeSwitch],
                      [UIBarButtonItem flexibleSpaceItem],
                      nil];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = items;

	UILabel* tv = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    tv.text = @"Buyer's Guide";
    tv.textAlignment = UITextAlignmentCenter;
    tv.adjustsFontSizeToFitWidth = YES;
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont boldSystemFontOfSize:19];
    tv.shadowColor = [UIColor darkGrayColor];
    self.navigationItem.titleView = tv;
		
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self toggleViews:modeSwitch];
            
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(categorySelectedWithNotification:) 
                                                 name:DidSelectCategoryNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(brandSelectedWithNotification:) 
                                                 name:DidSelectBrandNotification 
                                               object:nil];
    
    

	[self preloadAllBrandsFetchedResultsController];
}

-(void)toggleViews:(id)sender{
    
    if([(UISegmentedControl*)sender selectedSegmentIndex]==0){
        
        [self loadCategories];
        
    }else {
        
        [self loadCompanies];
    }
    
}

- (void)loadCategories{
    
    [companyView viewWillDisappear:NO];
    [companyView.view removeFromSuperview];
    
    if(categoryView==nil){
		self.categoryView = [[[CategoriesTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
		categoryView.managedObjectContext = self.managedObjectContext;
        CGRect f = self.view.bounds;
        f.size.height = f.size.height-35;
        categoryView.view.frame = f;
	}

    [self.view addSubview:categoryView.view];
    [categoryView viewWillAppear:NO];
    
}

- (void)loadCompanies{
    
    [categoryView viewWillDisappear:NO];
    [categoryView.view removeFromSuperview];
    
    if(companyView==nil){
		self.companyView = [[[CompaniesTableViewController alloc] init] autorelease];
		companyView.managedObjectContext = self.managedObjectContext;
        CGRect f = self.view.bounds;
        companyView.view.frame = f;
	}
      
	[self.view addSubview:companyView.view];	
    [companyView viewWillAppear:NO];
    
}

- (void)showKey{
    
    KeyViewController *detailViewController = [[KeyViewController alloc] initWithNibName:@"KeyView" bundle:nil];
    [self presentModalViewController:detailViewController animated:YES];
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

- (void)brandSelectedWithNotification:(NSNotification*)note{
    
    // Navigation logic may go here -- for example, create and push another view controller.
    BGBrand* selectedBrand = (BGBrand*)[note object];
    
	BrandViewController *detailViewController = [[BrandViewController alloc] initWithBrand:selectedBrand]; 
    
    detailViewController.view.frame = self.view.bounds;		
    self.brandController = detailViewController;
    [detailViewController release];
    
    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:brandController animated:YES];    
    
}

#pragma mark -
#pragma mark BrandsFetchedResultsController


- (void)preloadAllBrandsFetchedResultsController{
    
	if(companyView==nil){
	
		self.companyView = [[[CompaniesTableViewController alloc] init] autorelease];
		companyView.managedObjectContext = self.managedObjectContext;
        CGRect f = self.view.bounds;
        companyView.view.frame = f;
		[companyView fetchAndReload];
	}
} 




@end

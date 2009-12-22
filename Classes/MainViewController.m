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
#import "Category.h"
#import "Company.h"
#import "FilteredCompaniesViewController.h"
#import "CompanyViewController.h"
#import "UIView-Extensions.h"
#import "KeyViewController.h"
#import "UIBarButtonItem+extensions.h"

@implementation MainViewController

@synthesize categoryView;
@synthesize modeSwitch;
@synthesize managedObjectContext;
@synthesize companyView;



- (void)dealloc {
    self.companyView = nil;
    self.categoryView = nil;
    [super dealloc];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DidSelectCategoryNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DidSelectCompanyNotification 
                                                  object:nil];
    
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
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
    
    //self.title = @"Buying For Equality";
	
	UILabel* tv = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    tv.text = @"Buying For Equality";
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
    self.navigationController.toolbarHidden = NO;
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
                                             selector:@selector(companySelectedWithNotification:) 
                                                 name:DidSelectCompanyNotification 
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
	}
    
	categoryView.view.frame = self.view.bounds;
	//[categoryView.view setOriginY:44];
	//[categoryView.view setSizeHeight:416-44-36-44];
	[categoryView.view setSizeHeight:416-44-36];
    [self.view addSubview:categoryView.view];
    [categoryView viewWillAppear:NO];
    
}

- (void)loadCompanies{
    
        
    [categoryView viewWillDisappear:NO];
    [categoryView.view removeFromSuperview];
        

    if(companyView==nil){
		self.companyView = [[[CompaniesTableViewController alloc] init] autorelease];
		companyView.managedObjectContext = self.managedObjectContext;
	}
      
	companyView.view.frame = self.view.bounds;
    //[companyView.view setOriginY:44];
	//[companyView.view setSizeHeight:416-44-36-44];
	[self.view addSubview:companyView.view];	
    [companyView viewWillAppear:NO];
    
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
    
    UIAlertView* message = [[UIAlertView alloc] initWithTitle:@"Donate"
                                                      message:donationText 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                            otherButtonTitles:@"Donate", nil];
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
    Category* selectedCat = (Category*)[note object];
    FilteredCompaniesViewController *detailViewController = [[FilteredCompaniesViewController alloc] initWithContext:self.managedObjectContext 
                                                                                                                           key:@"categories" 
                                                                                                                         value:selectedCat];
    detailViewController.view.frame = self.view.bounds;
    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}

- (void)companySelectedWithNotification:(NSNotification*)note{
    
    // Navigation logic may go here -- for example, create and push another view controller.
    Company* selectedCompany = (Company*)[note object];
    
    CompanyViewController *detailViewController = [[CompanyViewController alloc] initWithCompany:selectedCompany 
                                                                                        category:nil]; 
    
    detailViewController.view.frame = self.view.bounds;
    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    
}

#pragma mark -
#pragma mark BrandsFetchedResultsController


- (void)preloadAllBrandsFetchedResultsController{
    
	if(companyView==nil){
	
		self.companyView =[[[CompaniesTableViewController alloc] init] autorelease];
		companyView.managedObjectContext = self.managedObjectContext;
		[companyView fetch];
	}
} 




@end

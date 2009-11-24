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
#import "FilteredCompaniesTableViewController.h"
#import "CompanyViewController.h"
#import "UIView-Extensions.h"
#import "KeyViewController.h"
#import "UIBarButtonItem+extensions.h"

@implementation MainViewController

@synthesize categoryView;
@synthesize modeSwitch;
@synthesize context;
@synthesize companyView;

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
                                                                     
    /*
    UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info2.png"]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithView:iv];
    [self.navigationItem.rightBarButtonItem setTarget:self];
    [self.navigationItem.rightBarButtonItem setAction:@selector(showKey)];
    [iv release];
    */
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"info2.png"] 
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self 
                                                                     action:@selector(showKey)];
    
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:@"Donate" 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(ShowDonationMessage)];
    
    self.title = @"Buying Guide";
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
    
        
    if(categoryView==nil)
        self.categoryView = [[[CategoriesTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    
    categoryView.managedObjectContext = self.context;
    
    categoryView.view.frame = self.view.bounds;
    [categoryView.view setSizeHeight:416-44-36];
    
    [self.view addSubview:categoryView.view];
    
    [categoryView viewWillAppear:NO];
    
}

- (void)loadCompanies{
    
        
    [categoryView viewWillDisappear:NO];
    [categoryView.view removeFromSuperview];
        

    if(companyView==nil)
        self.companyView = [[[CompaniesTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    
    companyView.managedObjectContext = self.context;
    
    companyView.view.frame = self.view.bounds;
    [self.view addSubview:companyView.view];
    
    [companyView viewWillAppear:NO];
    
}

- (void)showKey{
    
    KeyViewController *detailViewController = [[KeyViewController alloc] init];
    
    //[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController presentModalViewController:detailViewController animated:YES];
    [detailViewController release];
    
}


- (void)ShowDonationMessage{
    
}

- (void)categorySelectedWithNotification:(NSNotification*)note{
    
    // Navigation logic may go here -- for example, create and push another view controller.
    Category* selectedCat = (Category*)[note object];
    FilteredCompaniesTableViewController *detailViewController = [[FilteredCompaniesTableViewController alloc] initWithContext:self.context 
                                                                                                                           key:@"categories" 
                                                                                                                         value:selectedCat];
    detailViewController.view.frame = self.view.bounds;
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Categories" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}

- (void)companySelectedWithNotification:(NSNotification*)note{
    
    // Navigation logic may go here -- for example, create and push another view controller.
    Company* selectedCompany = (Company*)[note object];
    
    CompanyViewController *detailViewController = [[CompanyViewController alloc] initWithCompany:selectedCompany 
                                                                                        category:nil]; 
    
    detailViewController.view.frame = self.view.bounds;
    //[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.companyView = nil;
    self.categoryView = nil;
    [super dealloc];
}


@end

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

@implementation MainViewController

@synthesize categoryView;
@synthesize modeSwitch;
@synthesize context;
@synthesize companyView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray* items = [NSArray arrayWithObjects:[UIBarButtonItem flexibleSpaceItem], 
                      [UIBarButtonItem itemWithView:modeSwitch], 
                      [UIBarButtonItem flexibleSpaceItem],
                      nil];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = items;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self toggleViews:modeSwitch];
            
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

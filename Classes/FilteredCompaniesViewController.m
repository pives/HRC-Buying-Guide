//
//  FilteredCompaniesViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/3/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "FilteredCompaniesViewController.h"
#import "FilteredCompaniesTableViewController.h"
#import "Category.h"
#import "KeyViewController.h"
#import "UIBarButtonItem+extensions.h"
#import "Category+Extensions.h"
#import "CompanyViewController.h"
#import "UIColor+extensions.h"

@implementation FilteredCompaniesViewController

@synthesize tableController;
@synthesize sortControl;
@synthesize index;


- (void)dealloc {
    self.index = nil;
    self.tableController = nil;
    self.sortControl = nil;
    [super dealloc];
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
       
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DidSelectFilteredCompanyNotification 
                                                  object:nil];
    
    
}

- (id)initWithContext:(NSManagedObjectContext*)context key:(NSString*)key value:(id)object{
    
    if(self = [super init]){
        
        self.tableController = [[[FilteredCompaniesTableViewController alloc] initWithContext:context key:key value:object] autorelease];
    }
    
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = NO;
    
    UISegmentedControl* control = [[[UISegmentedControl alloc] initWithItems:
                                    [NSArray arrayWithObjects:
                                     @"Rating", 
                                     @"Alphabetically",
                                     nil]] autorelease];
    
    control.segmentedControlStyle = UISegmentedControlStyleBar;
    [control setWidth:155 forSegmentAtIndex:0];
    [control setWidth:155 forSegmentAtIndex:1];
    control.selectedSegmentIndex = 0;
    [control addTarget:self action:@selector(changeSort:) forControlEvents:UIControlEventValueChanged];
    
    
    NSArray* items = [NSArray arrayWithObjects:[UIBarButtonItem flexibleSpaceItem], 
                      [UIBarButtonItem itemWithView:control], 
                      [UIBarButtonItem flexibleSpaceItem],
                      nil];
    
    self.toolbarItems = items;
    
    self.sortControl = control;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"info2small.png"] 
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self 
                                                                     action:@selector(showKey)];
    
    UILabel* tv = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    tv.text = [(Category*)[tableController filterObject] nameDisplayFriendly];
    tv.textAlignment = UITextAlignmentCenter;
    tv.adjustsFontSizeToFitWidth = YES;
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont boldSystemFontOfSize:19];
    tv.shadowColor = [UIColor darkGrayColor];
    self.navigationItem.titleView = tv;

    tableController.view.frame = self.view.bounds;;
    [self.view addSubview:tableController.view];

    UIColor* g = [UIColor gpGreenHeader];
    UIColor* y = [UIColor gpYellowHeader];
    UIColor* r = [UIColor gpRedHeader];
    
    NSArray* colors = [NSArray arrayWithObjects:g, y, r, nil];
    
    CGRect myFrame = CGRectMake(296, 65, 16, 300);
    
    self.index = [[[FJSTableViewColorIndex alloc] initWithFrame:myFrame colors:colors gradient:NO] autorelease];
    [index setDelegate:self];
    [self.view addSubview:index];
    
    [self changeSort:self];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    [self.tableController viewWillAppear:animated];
        
}


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
        
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(companySelectedWithNotification:) 
                                                 name:DidSelectFilteredCompanyNotification 
                                               object:nil];
    
    
}

- (void)didTouchSegment:(int)segment inColorIndex:(FJSTableViewColorIndex*)index{
    
    if(segment == 0){
        
        [tableController.tableView scrollToRowAtIndexPath:[tableController sectionIndexOfGreenSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }else if(segment == 1){
        
        [tableController.tableView scrollToRowAtIndexPath:[tableController sectionIndexOfYellowSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];

    }else {
     
        [tableController.tableView scrollToRowAtIndexPath:[tableController sectionIndexOfRedSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];

    }


    
}

- (IBAction)changeSort:(id)sender{
    
    tableController.mode = sortControl.selectedSegmentIndex;
    [tableController fetch];    
    
    if(sortControl.selectedSegmentIndex == 0){
        index.alpha = 1;
               
    }else{
        index.alpha = 0;
    }
}

- (void)showKey{
    
    KeyViewController *detailViewController = [[KeyViewController alloc] init];
    
    //[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController presentModalViewController:detailViewController animated:YES];
    [detailViewController release];
    
}


- (void)scrollToRedSection{
    
    int section;
    
    if(section < 0 )
        section = 0;
    
    [tableController.tableView scrollToRowAtIndexPath:[tableController sectionIndexOfRedSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    
}

- (void)scrollToYellowSection{
    
    int section = 1;
    
    if(section < 0 )
        section = 0;
    
    [tableController.tableView scrollToRowAtIndexPath:[tableController sectionIndexOfYellowSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    
    
}

- (void)scrollToGreenSection{
    
    int section = 0;
    
    if(section < 0 )
        section = 0;
    
    [tableController.tableView scrollToRowAtIndexPath:[tableController sectionIndexOfGreenSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    
    
}

- (void)companySelectedWithNotification:(NSNotification*)note{
    
    Company* selectedCompany = (Company*)[note object];
    
    CompanyViewController *detailViewController = [[CompanyViewController alloc] initWithCompany:selectedCompany 
                                                                                        category:(Category*)tableController.filterObject]; 
    
    detailViewController.view.frame = self.view.bounds;
    //[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    //[self performSelector:@selector(deselectIndexPath:) withObject:indexPath afterDelay:0.25];
        
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end

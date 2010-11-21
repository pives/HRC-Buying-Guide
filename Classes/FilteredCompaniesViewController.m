//
//  FilteredCompaniesViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/3/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "FilteredCompaniesViewController.h"
#import "FilteredCompaniesTableViewController.h"
#import "BGCategory.h"
#import "KeyViewController.h"
#import "UIBarButtonItem+extensions.h"
#import "CompanyViewController.h"
#import "UIColor+extensions.h"

@implementation FilteredCompaniesViewController

@synthesize tableController;
@synthesize sortControl;
@synthesize index;
@synthesize companyController;




- (void)dealloc {
	self.companyController = nil;
    self.index = nil;
    self.tableController = nil;
    self.sortControl = nil;
    [super dealloc];
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
       
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
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
    tv.text = [(BGCategory*)[tableController filterObject] name];
    tv.textAlignment = UITextAlignmentCenter;
    tv.adjustsFontSizeToFitWidth = YES;
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont boldSystemFontOfSize:19];
    tv.shadowColor = [UIColor darkGrayColor];
    self.navigationItem.titleView = tv;

    tableController.view.frame = self.view.bounds;;
    [self.view addSubview:tableController.view];

    /*
    UIColor* g = [UIColor headerGreen];
    UIColor* y = [UIColor headerYellow];
    UIColor* r = [UIColor headerRed];
    
    NSArray* colors = [NSArray arrayWithObjects:g, y, r, nil];
    
    CGRect myFrame = CGRectMake(295, 66, 16, 300);
    
    self.index = [[[FJSTableViewColorIndex alloc] initWithFrame:myFrame colors:colors gradient:NO] autorelease];
    self.index.delegate = self;
	[self.view addSubview:index];
	*/
	
	
    CGRect myFrame = CGRectMake(295, 66, 16, 300);
    self.index = [[[FJSTableViewImageIndex alloc] initWithFrame:myFrame image:[UIImage imageNamed:@"slidernew.png"] sections:3] autorelease];
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(searchBeganWithNotification:) 
                                                 name:FilteredCompanySearchBegan 
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(searchEndedWithNotification:) 
                                                 name:FilteredCompanySearchEnded 
                                               object:nil];
    
    
}


- (void)searchBeganWithNotification:(NSNotification*)note{
	
	[index removeFromSuperview];

}

- (void)searchEndedWithNotification:(NSNotification*)note{
	
    [self.view addSubview:index];
}

- (void)didTouchSegment:(int)segment inColorIndex:(FJSTableViewImageIndex*)anIndex{
    
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
	[tableController reload];
    
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




- (void)companySelectedWithNotification:(NSNotification*)note{
    
    BGCompany* selectedCompany = (BGCompany*)[note object];
    
	
	if(self.companyController == nil){
		CompanyViewController *detailViewController = [[CompanyViewController alloc] initWithCompany:selectedCompany 
																							category:(BGCategory*)tableController.filterObject]; 
		
		detailViewController.view.frame = self.view.bounds;		
		self.companyController = detailViewController;
		[detailViewController release];

		
	}else{
		
		[companyController setCompany:selectedCompany 
							 category:(BGCategory*)tableController.filterObject];
	}
	
	
	[self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:companyController animated:YES];
        
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


@end

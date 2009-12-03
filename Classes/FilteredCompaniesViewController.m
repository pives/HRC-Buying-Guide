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

@implementation FilteredCompaniesViewController

@synthesize tableController;
@synthesize sortControl;
@synthesize red;
@synthesize yellow;
@synthesize green;


- (void)dealloc {
    self.tableController = nil;
    self.red = nil;
    self.yellow = nil;
    self.green = nil;
    self.sortControl = nil;
    [super dealloc];
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
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"info2.png"] 
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

    CGRect tableFrame = self.view.bounds;
    tableFrame.size.height += 44;
    tableController.view.frame = tableFrame;
    [self.view addSubview:tableController.view];
    
    self.red = [UIButton buttonWithType:UIButtonTypeCustom];
    [red setImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
    red.frame = CGRectMake(290, 330, 30, 30);
    [red addTarget:self action:@selector(scrollToRedSection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:red];
    
    self.yellow = [UIButton buttonWithType:UIButtonTypeCustom];
    [yellow setImage:[UIImage imageNamed:@"yellow.png"] forState:UIControlStateNormal];
    yellow.frame = CGRectMake(290, 200, 30, 30);
    [yellow addTarget:self action:@selector(scrollToYellowSection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:yellow];
    
    self.green = [UIButton buttonWithType:UIButtonTypeCustom];
    [green setImage:[UIImage imageNamed:@"green.png"] forState:UIControlStateNormal];
    green.frame = CGRectMake(290, 68, 30, 30);
    [green addTarget:self action:@selector(scrollToGreenSection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:green];

    [self changeSort:self];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    [self.tableController viewWillAppear:animated];
        
}


- (IBAction)changeSort:(id)sender{
    
    tableController.mode = sortControl.selectedSegmentIndex;
    [tableController fetch];    
    
    if(sortControl.selectedSegmentIndex == 0){
        red.alpha = 1;
        yellow.alpha = 1;
        green.alpha = 1;
               
    }else{
        red.alpha = 0;
        yellow.alpha = 0;
        green.alpha = 0;
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

//
//  MainViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "MainViewController.h"
#import "CategoriesTableViewController.h"
#import "UIBarButtonItem+extensions.h"

@implementation MainViewController

@synthesize categoryView;
@synthesize modeSwitch;
@synthesize context;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoryView = [[CategoriesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    CGRect frame = self.view.frame;
    frame.origin.y = self.view.frame.origin.y - 20;
    categoryView.view.frame = frame;
    [self.view addSubview:categoryView.view];
        
    NSArray* items = [NSArray arrayWithObjects:[UIBarButtonItem flexibleSpaceItem], 
                      [UIBarButtonItem itemWithView:modeSwitch], 
                      [UIBarButtonItem flexibleSpaceItem],
                      nil];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = items;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    categoryView.managedObjectContext = self.context;
    [categoryView viewWillAppear:animated];

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


- (void)dealloc {
    self.categoryView = nil;
    [super dealloc];
}


@end

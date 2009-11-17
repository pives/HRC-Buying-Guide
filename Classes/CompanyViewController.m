//
//  CompanyViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "CompanyViewController.h"
#import "Company.h"
#import "Company+Extensions.h"
#import "DataSource.h"
#import "PagingScrollViewController.h"

@implementation CompanyViewController

@synthesize company;
@synthesize nameLabel;
@synthesize scoreLabel;
@synthesize data;
@synthesize brands;


- (id)initWithCompany:(Company*)aCompany category:(Category*)aCategory{
    
    if(self = [super init]){
                    
        self.data = [[[DataSource alloc] initWithCompany:aCompany category:aCategory] autorelease];
        
        NSDictionary* myData = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil];
        
        NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:myData, UINibExternalObjects, nil];
        
        [[NSBundle mainBundle] loadNibNamed:@"CompanyViewController" owner:self options:options];
        
        self.company = aCompany;
        
    }
    
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// not called when i do the loadnib thing
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",@"load!");

}

- (void)awakeFromNib{
    
    
    NSLog(@"%@",@"awake!");
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.scoreLabel.text = company.ratingFormatted;
    self.nameLabel.text = company.name;

    
}


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
    self.brands = nil;
    self.data = nil;
    self.nameLabel = nil;
    self.scoreLabel = nil;
    self.company = nil;
    [super dealloc];
}


@end

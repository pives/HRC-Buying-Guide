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
#import "UIBarButtonItem+extensions.h"
#import "UIColor+extensions.h"

@implementation CompanyViewController

@synthesize company;
@synthesize nameLabel;
@synthesize scoreLabel;
@synthesize data;
@synthesize brands;
@synthesize scoreBackgroundColor;

- (id)initWithCompany:(Company*)aCompany category:(Category*)aCategory{
    
    if(self = [super init]){
                    
        self.data = [[[DataSource alloc] initWithCompany:aCompany category:aCategory] autorelease];
        NSDictionary* myData = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil];
        NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:myData, UINibExternalObjects, nil];
        
        [[NSBundle mainBundle] loadNibNamed:@"CompanyViewController" owner:self options:options];
        
        self.company = aCompany;
        
        [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithTitle:@"Score Card" 
                                                                            style:UIBarButtonItemStyleBordered 
                                                                           target:self 
                                                                           action:@selector(showScoreCard)]];
        
        self.toolbarItems = [NSArray arrayWithObjects: 
                             [UIBarButtonItem flexibleSpaceItem],
                             [UIBarButtonItem systemItem:UIBarButtonSystemItemAction 
                                                  target:nil 
                                                  action:@selector(sendEmail)],
                             nil];
        
        
        if([company.ratingLevel intValue] == 0)
            scoreBackgroundColor.backgroundColor = [UIColor gpGreen];
        else if([company.ratingLevel intValue] == 1)
            scoreBackgroundColor.backgroundColor = [UIColor gpYellow];
        else 
            scoreBackgroundColor.backgroundColor = [UIColor gpRed];
        
        
    }
    
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// not called when i do the loadnib thing
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",@"load!");

}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.scoreLabel.text = company.ratingFormatted;
    self.nameLabel.text = company.name;
    //self.navigationController.toolbarHidden = YES;
    [brands viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [brands viewWillAppear:animated];
    
}

- (void)showScoreCard{
    
}

- (void)sendEmail{
    
    
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
    self.brands = nil;
    self.data = nil;
    self.nameLabel = nil;
    self.scoreLabel = nil;
    self.company = nil;
    [super dealloc];
}


@end

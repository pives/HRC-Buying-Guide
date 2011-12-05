//
//  CompanyScoreCardViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "CompanyScoreCardViewController.h"
#import "BGCompany.h"
#import "NSString+extensions.h"
#import "UIBarButtonItem+extensions.h"

@implementation CompanyScoreCardViewController

@synthesize bar;
@synthesize spinner;
@synthesize tableView;
@synthesize totalLabel;

- (void)dealloc {
    self.spinner = nil;
    self.tableView = nil;
    self.totalLabel = nil;
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (id)initWithCompany:(BGCompany*)aCompany
{
    self = [super initWithNibName:@"CompanyScoreCardView" bundle:nil];
    if (self != nil) {
        self.title = @"Score Card";
        
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.toolbarHidden = YES;
    
    self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithView:self.spinner];
	
	/*
	NSMutableArray* items = [bar.items mutableCopy];
	
	
        
    [items insertObject:[UIBarButtonItem fixedSpaceItemOfSize:12]  atIndex:0];
    [items insertObject:[UIBarButtonItem itemWithView:self.spinner] atIndex:0];
    
    bar.items = items;
    [items release];
    */
	
                        
}

- (void)viewWillAppear:(BOOL)animated{
    
    [spinner startAnimating];
    
}

#pragma mark - UITableView Delegate & Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}



- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    
    static int IconImageViewTag = 243;
    static int DescriptionLabelTag = 244;
    static int RatingLabelTag = 245;
    
    UIImageView *iconImageView;
    UILabel *descriptionLabel;
    UILabel *ratingLabel;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 7.0, 30.0, 30.0)];
        iconImageView.tag = IconImageViewTag;
        [cell addSubview:iconImageView];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 7.0, 200.0, 30.0)];
        descriptionLabel.tag = DescriptionLabelTag;
        descriptionLabel.numberOfLines = 2;
        descriptionLabel.font = [UIFont systemFontOfSize:13.0];
        [cell addSubview:descriptionLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0, 7.0, 60.0, 30.0)];
        ratingLabel.tag = RatingLabelTag;
        ratingLabel.textColor = [UIColor greenColor];
        ratingLabel.font = [UIFont systemFontOfSize:15.0];
        [cell addSubview:ratingLabel];
    }
    
    iconImageView = (UIImageView *)[cell viewWithTag:IconImageViewTag];
    iconImageView.image = [UIImage imageNamed:@""];
    
    descriptionLabel = (UILabel *)[cell viewWithTag:DescriptionLabelTag];
    descriptionLabel.text = @"";
    
    ratingLabel = (UILabel *)[cell viewWithTag:RatingLabelTag];
    ratingLabel.text = @"";
    
    return cell;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	[self done];
	
}

                        

- (IBAction)done{
    
    [self dismissModalViewControllerAnimated:YES];
}


@end

//
//  CompanyScoreCardViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "CompanyScoreCardViewController.h"
#import "BGScorecard.h"
#import "BGCompany.h"
#import "NSString+extensions.h"
#import "UIBarButtonItem+extensions.h"
#import "UIColor+extensions.h"
#import "Company+Extensions.h"
#import "NSManagedObjectContext+Extensions.h"
#import "SharingManager.h"
#import "BALabel.h"

@implementation CompanyScoreCardViewController

@synthesize tableView;
@synthesize totalLabel;
@synthesize finalTotalBGView;
@synthesize scoreBGView;
@synthesize scoreLabel;
@synthesize company;
@synthesize fetchedResultsController;


- (void)dealloc {
    self.tableView = nil;
    self.totalLabel = nil;
    self.finalTotalBGView = nil;
    self.scoreLabel = nil;
    self.scoreBGView = nil;
    self.company = nil;
    self.fetchedResultsController = nil;
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
        self.company = aCompany;
        

    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.finalTotalBGView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"finalRatingPattern.png"]];
    
	UIColor* color; 
	
    if([self.company.ratingLevel intValue] == 0)
        color = [UIColor cellGreen];
    else if([company.ratingLevel intValue] == 1)
        color = [UIColor cellYellow];
    else 
        color = [UIColor cellRed];
    
    self.scoreBGView.backgroundColor = color;
    
    self.scoreLabel.text = self.company.ratingFormatted;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    
    [SharingManager sharedSharingManager].viewController = self;
    [SharingManager sharedSharingManager].company = self.company;
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" 
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:[SharingManager sharedSharingManager] 
                                                                   action:@selector(showSharingOptions)];
    [self.navigationItem setRightBarButtonItem:shareButton];
    [shareButton release];

	
                        
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchAndReload];
    
	self.navigationController.toolbarHidden = YES;
}


#pragma mark Fetching

- (void)fetchAndReload{
    
    self.fetchedResultsController = nil;
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[self.company.managedObjectContext resetCoreDataStore];
		[self.company.managedObjectContext displayCcoreDataError];
	}
    
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSManagedObjectContext *managedObjectContext = self.company.managedObjectContext;

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BGScorecard" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setFetchBatchSize:20];
	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(company == %@)", self.company]];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	
	return fetchedResultsController;
} 

#pragma mark - UITableView Delegate & Datasource

-(CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 128.0;
    
	BGScorecard *scorecard = (BGScorecard*)[fetchedResultsController objectAtIndexPath:indexPath];
    CGSize size = [scorecard.policyDescription sizeWithFont:[UIFont systemFontOfSize:14]
                                          constrainedToSize:CGSizeMake(232.0,400.0)
                                              lineBreakMode:UILineBreakModeWordWrap]; 
    return size.height + 15.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    NSUInteger count = [[fetchedResultsController sections] count];
    return (count == 0) ? 1 : count;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {

	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}



- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    
    static int IconImageViewTag = 243;
    static int DescriptionLabelTag = 244;
    static int RatingLabelTag = 245;
    
    UIImageView *iconImageView;
    UILabel *descriptionLabel;
    UILabel *ratingLabel;
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        cell.backgroundColor = [UIColor clearColor];
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 7.0, 30.0, 30.0)];
        iconImageView.tag = IconImageViewTag;
        iconImageView.backgroundColor = [UIColor clearColor];
        [cell addSubview:iconImageView];
        [iconImageView release];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 5.0, 232.0, 120.0)];
        descriptionLabel.tag = DescriptionLabelTag;
        descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.numberOfLines = 7;
//        descriptionLabel.adjustsFontSizeToFitWidth = YES;
//        descriptionLabel.minimumFontSize = 11.0;
        descriptionLabel.font = [UIFont systemFontOfSize:14];
        [cell addSubview:descriptionLabel];
        [descriptionLabel release];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(277.0, 5.0, 33.0, 25.0)];
        ratingLabel.tag = RatingLabelTag;
        ratingLabel.backgroundColor = [UIColor clearColor];
        ratingLabel.textAlignment = UITextAlignmentCenter;
        ratingLabel.font = [UIFont systemFontOfSize:18.0];
        [cell addSubview:ratingLabel];
        [ratingLabel release];
    }
    
	BGScorecard *scorecard = (BGScorecard*)[fetchedResultsController objectAtIndexPath:indexPath];
    
    iconImageView = (UIImageView *)[cell viewWithTag:IconImageViewTag];
    descriptionLabel = (UILabel *)[cell viewWithTag:DescriptionLabelTag];
    ratingLabel = (UILabel *)[cell viewWithTag:RatingLabelTag];
    
    if ([scorecard.policyRating intValue] > 0) {
        iconImageView.image = [UIImage imageNamed:@"check.png"];
        ratingLabel.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
    } else {
        iconImageView.image = [UIImage imageNamed:@"x.png"];
        ratingLabel.textColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
    }
    
    CGSize size = [scorecard.policyDescription sizeWithFont:[UIFont systemFontOfSize:14]
                                          constrainedToSize:CGSizeMake(232.0,400.0)
                                              lineBreakMode:UILineBreakModeWordWrap];
    descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x,
                                        descriptionLabel.frame.origin.y,
                                        descriptionLabel.frame.size.width,
                                        size.height);
    descriptionLabel.text = scorecard.policyDescription;
    
    ratingLabel.text = [NSString stringWithFormat:@"%@%@", [scorecard.policyRating intValue] > 0 ? @"+" : @"", scorecard.policyRating];
    
    return cell;
}



             

@end

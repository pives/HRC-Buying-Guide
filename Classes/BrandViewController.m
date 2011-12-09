//
//  CompanyViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "BrandViewController.h"
#import "BGCompany.h"
#import "BGCategory.h"
#import "Company+Extensions.h"
#import "BGBrand.h"
#import "UIBarButtonItem+extensions.h"
#import "UIColor+extensions.h"
#import "CompanyScoreCardViewController.h"
#import "HRCBrandTableViewController.h"
#import "FilteredCompaniesViewController.h"
#import "DebugLog.h"
#import "LKBadgeView.h"
#import "BALabel.h"
#import "SharingManager.h"



static NSString *AllCategoriesKey = @"AllCategories";

/*
static CGSize nameRectMaxSize = {240,80};
static CGSize partnerImageSize = {14,14};

static CGPoint partnerImageOrigin = {2,34};
*/
@implementation BrandViewController

@synthesize company;
@synthesize brand;
@synthesize category;
@synthesize companyCategories;
@synthesize companyCategoryCounts;
@synthesize brandLabel;
@synthesize categoryLabel;
@synthesize scoreLabel;
@synthesize companyLabel;
@synthesize scoreBackgroundColor;
@synthesize partnerIcon;
@synthesize categoriesTableView;
@synthesize findAlternateView;
@synthesize scorecardButton;
@synthesize tableHeaderView;
@synthesize companyView;



#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    self.brandLabel = nil;
    self.companyLabel = nil;
    self.categoryLabel = nil;
    self.scoreBackgroundColor = nil;
    self.partnerIcon = nil;
    self.scoreLabel = nil;
    self.brand = nil;
    self.company = nil;
    self.category = nil;
    self.companyCategories = nil;
    self.companyCategoryCounts = nil;
    self.categoriesTableView = nil;
    self.findAlternateView = nil;
    self.tableHeaderView = nil;
    self.companyView = nil;
    [scorecardButton release];
    [super dealloc];
}



- (id)initWithBrand:(BGBrand*)aBrand {
    
    if(self = [super initWithNibName:@"BrandViewController" bundle:nil]){
		
		[self setBrand:aBrand];
		
		
		/*
		 NSDictionary* myData = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil];
		 NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:myData, UINibExternalObjects, nil];
		 */ 
		/*
		[self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithTitle:@"Score Card" 
																			style:UIBarButtonItemStyleBordered 
																		   target:self 
																		   action:@selector(showScoreCard)]];
		
		self.toolbarItems = [NSArray arrayWithObjects: 
							 [UIBarButtonItem flexibleSpaceItem],
							 [UIBarButtonItem itemWithTitle:@"Share" style:UIBarButtonItemStyleBordered 
												  target:self 
												  action:@selector(launchActionSheet)],
							 nil];
		
		
		*/
        
        [SharingManager sharedSharingManager].viewController = self;
        [SharingManager sharedSharingManager].company = self.company;
		[self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithTitle:@"Share" style:UIBarButtonItemStyleBordered 
																		   target:[SharingManager sharedSharingManager] 
																		   action:@selector(showSharingOptions)]];

                                     
        
        
    }
    
    return self;
}

#pragma mark -
#pragma mark UIViewController


- (void)viewDidUnload {
    [self setScorecardButton:nil];
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated{
	
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

static float kBrandNameFontSize = 19.0;


// not called when i do the loadnib thing
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoriesTableView.rowHeight  = 44.0;
    

    //self.brandLabel.verticalAlignment = BAVerticalAlignmentCenter;
    self.brandLabel.font = [UIFont boldSystemFontOfSize:kBrandNameFontSize];
    self.brandLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.brandLabel.backgroundColor = [UIColor clearColor];
    self.brandLabel.shadowColor = [UIColor whiteColor];
    self.brandLabel.shadowOffset = CGSizeMake(0.0,1.0);
    self.brandLabel.numberOfLines = 2;
    self.brandLabel.minimumFontSize = 13.0;
    self.brandLabel.adjustsFontSizeToFitWidth = YES;
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
	
    self.scoreLabel.text = self.company.ratingFormatted;
    self.brandLabel.text = self.brand.name;
    self.companyLabel.text = self.company.name;
    self.categoryLabel.text = self.category.name;
    
    if([company.nonResponder boolValue] == YES){
        
        self.brandLabel.font = [UIFont italicSystemFontOfSize:kBrandNameFontSize];
        self.scoreLabel.font = [UIFont italicSystemFontOfSize:24];
        
    }else{
        
        self.brandLabel.font = [UIFont boldSystemFontOfSize:kBrandNameFontSize];
        self.scoreLabel.font = [UIFont boldSystemFontOfSize:24];
    }    
	
	UIColor* color; 
	
    if([company.ratingLevel intValue] == 0)
        color = [UIColor cellGreen];
    else if([company.ratingLevel intValue] == 1)
        color = [UIColor cellYellow];
    else 
        color = [UIColor cellRed];
    
	scoreBackgroundColor.backgroundColor = color;
	
	[self layoutPartnerImageAndCompanyLabel];
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
	
    [self.navigationController setToolbarHidden:YES animated:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(categorySelectedWithNotification:) 
                                                 name:BrandsTableCategoryButtonTouchedNotification 
                                               object:nil];
    
	
}

#pragma mark -
#pragma mark Setup


- (void)setBrand:(BGBrand*)aBrand {
	
	brand = aBrand;
	self.company = [[self.brand companies] anyObject];
    self.category = [[self.brand categories] anyObject];
    self.companyCategories = [[self.company categories] allObjects];
    
    self.companyCategoryCounts = [NSMutableDictionary dictionaryWithCapacity:self.companyCategories.count+1];
    
    NSManagedObjectContext *context = self.brand.managedObjectContext;
    NSFetchRequest *req;
    NSUInteger count;
    NSError *error = nil;
    
    req = [NSFetchRequest fetchRequestWithEntityName:@"BGBrand"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"(includeInIndex == %@) AND (%@ IN companies)", [NSNumber numberWithBool:YES], self.company]];
    count = [context countForFetchRequest:req error:&error];
    if (error == nil)
        [self.companyCategoryCounts setObject:[NSNumber numberWithInt:count] forKey:AllCategoriesKey];

    
    for (BGCategory *cat in self.companyCategories) {
        error = nil;
        req = [NSFetchRequest fetchRequestWithEntityName:@"BGBrand"];
        [req setPredicate:[NSPredicate predicateWithFormat:@"(includeInIndex == %@) AND (%@ IN companies) AND (%@ IN categories)", [NSNumber numberWithBool:YES], self.company, cat]];
        count = [context countForFetchRequest:req error:&error];
        if (error == nil)
            [self.companyCategoryCounts setObject:[NSNumber numberWithInt:count] forKey:cat.name];

    }
    
}



- (void)layoutPartnerImageAndCompanyLabel{
	
	if(![company.partner boolValue]){
		
		self.partnerIcon.alpha = 0;
        CGRect f = self.brandLabel.frame;
        f.origin.x = 10;
        f.size.width = 205;
		self.brandLabel.frame = f;
       
        f = self.categoryLabel.frame;
        f.origin.x = 10;
        f.size.width = 205;
		self.categoryLabel.frame = f;
        
	}else{
		
		self.partnerIcon.alpha = 1;
        CGRect f = self.brandLabel.frame;
        f.origin.x = 32;
        f.size.width = 205 - 22;
		self.brandLabel.frame = f;
        
        f = self.categoryLabel.frame;
        f.origin.x = 32;
        f.size.width = 205 - 22;
		self.categoryLabel.frame = f;
        
		/*
		CGSize nameBoundingBox = [nameLabel.text sizeWithFont:nameLabel.font
											constrainedToSize:nameLabel.frame.size
												lineBreakMode:nameLabel.lineBreakMode];
		
		if(nameBoundingBox.width > (nameRectMaxSize.width - partnerImageSize.width - 4)){
			
			//label text WILL overlap icon, resize label to compensate
			nameLabel.frame = nameRectPartner;
			
			//setting image to original position
			self.partnerIcon.frame = CGRectMake(partnerImageOrigin.x, 
												partnerImageOrigin.y, 
												partnerImageSize.width, 
												partnerImageSize.height);
		
			
		}else{
			//label text will NOT overlap icon, move icon closer to look good			
			self.partnerIcon.frame = CGRectMake(floorf((nameRectMaxSize.width - nameBoundingBox.width)/2 - partnerImageSize.width - 6), 
												partnerImageOrigin.y, 
												partnerImageSize.width, 
												partnerImageSize.height);
			
			nameLabel.frame = nameRectNonPartner;
			
			
		}
		 */
	}
}

#pragma mark -
#pragma mark More Brands View Controller

- (void)categorySelectedWithNotification:(NSNotification*)note{
    
    // Navigation logic may go here -- for example, create and push another view controller.
    BGCategory* selectedCat = (BGCategory*)[note object];
    FilteredCompaniesViewController *detailViewController = [[FilteredCompaniesViewController alloc] initWithContext:company.managedObjectContext 
                                                                                                  filteredOnCategory:selectedCat
                                                                                                   filteredOnCompany:nil];
    detailViewController.view.frame = self.view.bounds;
    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}


- (void)showOtherBrandsCategory:(id)sender{
	
    [[NSNotificationCenter defaultCenter] postNotificationName:BrandsTableCategoryButtonTouchedNotification 
														object:self.category];   
}

#pragma mark -
#pragma mark Scorecard

- (IBAction)showScoreCard{
    
    CompanyScoreCardViewController* vc = [[[CompanyScoreCardViewController alloc] initWithCompany:self.company] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    
}



#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.companyCategories.count + 1;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Other brands";
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    static int badgeTag = 849;
    
    LKBadgeView* badgeView;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        badgeView = [[LKBadgeView alloc] initWithFrame:CGRectMake(240, 12, 50, 22)];
        badgeView.textColor = [UIColor whiteColor];
        badgeView.badgeColor = [UIColor colorWithHexString:@"8B98B3"];
        [cell addSubview:badgeView];
        badgeView.tag = badgeTag;
        //badgeView.widthMode = LKBadgeViewWidthModeSmall;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    
    NSNumber *count;
    
    badgeView = (LKBadgeView *)[cell viewWithTag:badgeTag];
    if (indexPath.row == self.companyCategories.count) {
        cell.textLabel.text = @"All Brands";
        count = [self.companyCategoryCounts objectForKey:AllCategoriesKey];
    } else {
        BGCategory *cat = [self.companyCategories objectAtIndex:indexPath.row];
        cell.textLabel.text = cat.name;
        count = [self.companyCategoryCounts objectForKey:cat.name];
    }
    
    NSString *countString;
    if (count != nil)
        countString = [count stringValue];
    else 
        countString = @"0";
    badgeView.text = countString;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BGCategory *cat;
    
    if (indexPath.row == self.companyCategories.count)
        cat = nil;
    else
        cat = [self.companyCategories objectAtIndex:indexPath.row];
               
    FilteredCompaniesViewController *detailViewController = [[FilteredCompaniesViewController alloc] initWithContext:company.managedObjectContext 
                                                                                                  filteredOnCategory:cat
                                                                                                   filteredOnCompany:self.company];
    detailViewController.view.frame = self.view.bounds;
    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}





@end

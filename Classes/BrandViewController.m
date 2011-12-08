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
#import "FJSTweetViewController.h"
#import "FJSTweetViewController+HRC.h"
#import "DebugLog.h"
#import "LKBadgeView.h"
#import "BALabel.h"




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
@synthesize tableHeaderView;
@synthesize agent;
@synthesize companyView;



#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [agent release], agent = nil;
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
		[self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithTitle:@"Share" style:UIBarButtonItemStyleBordered 
																		   target:self 
																		   action:@selector(launchActionSheet)]];

                                     
        
        
    }
    
    return self;
}

#pragma mark -
#pragma mark UIViewController


- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated{
	
	self.navigationController.toolbarHidden = NO;	

}

- (void)viewWillDisappear:(BOOL)animated{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


// not called when i do the loadnib thing
- (void)viewDidLoad {
    [super viewDidLoad];
    
    BALabel *baLabel = [[BALabel alloc] initWithFrame:CGRectMake(15, 0, 205, 54)];
    self.brandLabel = baLabel;
    [baLabel release];
    [self.companyView addSubview:self.brandLabel];
    self.brandLabel.verticalAlignment = BAVerticalAlignmentBottom;
    self.brandLabel.font = [UIFont boldSystemFontOfSize:22];
    self.brandLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.brandLabel.backgroundColor = [UIColor clearColor];
    self.brandLabel.shadowColor = [UIColor whiteColor];
    self.brandLabel.shadowOffset = CGSizeMake(0.0,1.0);
    self.brandLabel.numberOfLines = 2;
    self.brandLabel.minimumFontSize = 15.0;
    self.brandLabel.adjustsFontSizeToFitWidth = YES;
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
	
    self.scoreLabel.text = self.company.ratingFormatted;
    self.brandLabel.text = self.brand.name;
    self.companyLabel.text = self.company.name;
    self.categoryLabel.text = self.category.name;
    
    if([company.nonResponder boolValue] == YES){
        
        self.brandLabel.font = [UIFont italicSystemFontOfSize:22];
        self.scoreLabel.font = [UIFont italicSystemFontOfSize:24];
        
    }else{
        
        self.brandLabel.font = [UIFont boldSystemFontOfSize:22];
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
	
	self.navigationController.toolbarHidden = YES;	
	
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
		self.brandLabel.frame = CGRectMake(15, 0, 205, self.brandLabel.frame.size.height);
	}else{
		
		self.partnerIcon.alpha = 1;
		self.brandLabel.frame = CGRectMake(32, 0, 198, self.brandLabel.frame.size.height);
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 79.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 77.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.tableHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.findAlternateView;
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
        
        badgeView = [[LKBadgeView alloc] initWithFrame:CGRectMake(240, 10, 50, 26)];
        badgeView.textColor = [UIColor whiteColor];
        badgeView.badgeColor = [UIColor darkGrayColor];
        [cell addSubview:badgeView];
        badgeView.tag = badgeTag;
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

#pragma mark -
#pragma mark MFMailComposeViewController

- (void)sendEmail{
    
    if([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Support LGBT Equality When You Shop"]; //TODO: add subject
        
        NSString* fileName;
        NSString* fileExtension = @"txt";
        NSString* emailText;
        
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		NSString* rawLink = [info objectForKey:@"AppStoreURL"];
		//NSString* appStoreID = [info objectForKey:@"AppStoreIDCompounds"];
		NSString* appStoreID = [info objectForKey:@"AppStoreID"];
		/*
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		NSString* urlPrefix = [info objectForKey:@"ScoreCardURLPrefix"];
		NSString* urlSuffix = [info objectForKey:@"ScoreCardURLSuffix"];
        NSString* companyID = [self.company.ID stringValue];
        NSString* companyScoreurl = [NSString stringWithFormat:@"%@%@%@", urlPrefix, companyID, urlSuffix];
		*/
		
        
        if([company.nonResponder boolValue] == YES){
            
            fileName = @"EmailConfused";
            NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
            NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            emailText = [NSString stringWithFormat:fileContenets, 
                         company.name,
                         [company.rating stringValue],
                         nil
                         ];
            
                    
        }else{
            
            if([company.ratingLevel intValue] == 0){
                
                //GOOD
                fileName = @"EmailHappy";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
                             company.name, 
                             [company.rating stringValue],
                             nil
                             ];
                
                
            }else if([company.ratingLevel intValue] == 1){
                
                //MIDDLE
                fileName = @"EmailIndifferent";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
                             company.name, 
                             [company.rating stringValue],
                             nil
                             ];
                
                
            }else{
                
                fileName = @"EmailSad";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
                             company.name, 
                             [company.rating stringValue],
                             nil
                             ];
                
            }
            
            
        }
		
		
               
        [controller setMessageBody:emailText isHTML:YES];
        [self presentModalViewController:controller animated:YES];
        [controller release];
        
    }else{
        
        UIAlertView* message = [[[UIAlertView alloc] initWithTitle:@"Cannot send email"
                                                          message:@"Email is currently unavailable. Please check your email settings and try again." 
                                                         delegate:self 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil] autorelease];
        [message show];
        
        
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	//TODO: Check result?
    [self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark FJSTweetViewController

- (void)postTweet{
	
	FJSTweetViewController* tvc = [[FJSTweetViewController alloc] initWithCompany:self.company];
	
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:tvc];
	nc.navigationBarHidden = YES;
	
	[self.navigationController presentModalViewController:nc animated:YES];
	
	[tvc release];
	[nc release];
}


#pragma mark -
#pragma mark Facebook

///////////////////////////////////////////////////////////////////////////////////////////////////
// This application will not work until you enter your Facebook application's API key here:

static NSString* kApiKey = @"a103b98ed528fc842fd1daa9c7c97713";

// Enter either your API secret or a callback URL (as described in documentation):
static NSString* kApiSecret = @"514d14ac9dd9ef105d5207ca62accd3e"; // @"<YOUR SECRET KEY>";


- (void)sendFacebookPost{
 
    if(self.agent == nil){
        
        self.agent = [[[FacebookAgent alloc] initWithApiKey:kApiKey ApiSecret:kApiSecret ApiProxy:nil] autorelease];
        agent.delegate = self;
    }
   
    
    NSString* someText;
	
    if([company.nonResponder boolValue] == YES){
        
        someText = 
        @"HRC’s Buying For Workplace Equality Guide gives %@ an unofficial score of %i%%. They have failed to respond to our survey despite repeated attempts.  For more information and to download the iPhone app visit http://bit.ly/buy4eq";

    }else{
        
        if([company.ratingLevel intValue] == 0){
            
            someText = 
            @"HRC’s Buying For Workplace Equality Guide rates %@ %i%%. They receive one of the highest workplace equality scores. For more information and to download the iPhone app visit http://bit.ly/buy4eq";
            
            
        }else if([company.ratingLevel intValue] == 1){
            
            someText = 
            @"HRC’s Buying For Workplace Equality Guide rates %@ %i%%. They receive a moderate workplace equality score.  For more information and to download the iPhone app visit http://bit.ly/buy4eq";
            
            
        }else{
            
            someText = 
            @"HRC’s Buying For Workplace Equality Guide rates %@ %i%%. They receive one of the lowest workplace equality scores.  For more information and to download the iPhone app visit http://bit.ly/buy4eq";
            
        }
        
    }
    
		
	someText = [NSString stringWithFormat:someText, company.name, [company.rating intValue]];
    

    [agent publishFeedWithName:@"HRC Buying for Workplace Equality iPhone App" //can put it here
				   captionText:someText 
					  imageurl:@"http://www.hrc.org/buyersguide2010/images/2011-iphone_icon-90x90.png" 
					   linkurl:@"http://www.hrc.org/iPhone" 
			 userMessagePrompt:[NSString stringWithFormat:@"Tell others about %@",company.name]];
    
}

- (void) facebookAgent:(FacebookAgent*)agent didLoadInfo:(NSDictionary*) info{
    
    DebugLog(@"request load info: %@", [info description]);

}

- (void) facebookAgent:(FacebookAgent*)agent requestFaild:(NSString*) message{
    
	NSLog(@"Facebook request failed: %@", message);
}


- (void) facebookAgent:(FacebookAgent*)agent loginStatus:(BOOL) loggedIn{
	
	if(loggedIn)
		DebugLog(@"loggedin");
	
	DebugLog(@"should be logged in");
	
}

- (void) facebookAgent:(FacebookAgent*)agent statusChanged:(BOOL) success{
	
	if(success){
        DebugLog(@"YES!");
    }
	else {
		DebugLog(@"NO!");
	}
}


- (void) facebookAgent:(FacebookAgent*)agent dialog:(FBDialog*)dialog didFailWithError:(NSError*)error{
	
	NSLog(@"Facebook dialog failed with error: %@", [error description]);
	
}


#pragma mark -
#pragma mark UIActionSheet

- (void)launchActionSheet{
    
    UIActionSheet* myActionSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Help spread the word about %@", company.name] 
                                                                delegate:self 
                                                       cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"Twitter", @"Facebook", @"Email", nil] autorelease];
    
        
    myActionSheet.actionSheetStyle=UIActionSheetStyleAutomatic;
    [myActionSheet showInView:self.view];
    
}




#pragma mark -
#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)modalViewSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    

    switch (buttonIndex)
    {
		case 0:
        {
            [self postTweet];
            break;
        }
		case 1:
        {
           [self sendFacebookPost];
            break;
        }
        case 2:
        {
            [self sendEmail];
            break;
        }
    }
}




@end

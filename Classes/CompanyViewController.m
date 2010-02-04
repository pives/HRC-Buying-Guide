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
#import "Brand.h"
#import "HRCBrandTableDataSource.h"
#import "PagingScrollViewController.h"
#import "UIBarButtonItem+extensions.h"
#import "UIColor+extensions.h"
#import "CompanyScoreCardViewController.h"
#import "HRCBrandTableViewController.h"
#import "FilteredCompaniesViewController.h"
#import "FJSTweetViewController.h"
#import "FJSTweetViewController+HRC.h"


static CGRect nameRectPartner = {
	{18+18,0},
	{222-18,80}
};

static CGRect nameRectNonPartner = {
	{18,0},
	{222,80}
};
/*
static CGSize nameRectMaxSize = {240,80};
static CGSize partnerImageSize = {14,14};

static CGPoint partnerImageOrigin = {2,34};
*/
@implementation CompanyViewController

@synthesize company;
@synthesize nameLabel;
@synthesize scoreLabel;
@synthesize data;
@synthesize brands;
@synthesize scoreBackgroundColor;
@synthesize partnerIcon;

#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    self.brands = nil;
    self.data = nil;
    self.nameLabel = nil;
    self.scoreLabel = nil;
    self.company = nil;
    [super dealloc];
}



- (id)initWithCompany:(Company*)aCompany category:(Category*)aCategory{
    
    if(self = [super initWithNibName:@"CompanyViewController" bundle:nil]){
		
		[self setCompany:aCompany category:aCategory];
		
		
		/*
		 NSDictionary* myData = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil];
		 NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:myData, UINibExternalObjects, nil];
		 */ 
		
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
		
		
    }
    
    return self;
}

#pragma mark -
#pragma mark UIViewController


- (void)viewDidUnload {
	self.brands = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewWillDisappear:(BOOL)animated{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


// not called when i do the loadnib thing
- (void)viewDidLoad {
    [super viewDidLoad];
    brands.data = self.data;
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.scoreLabel.text = company.ratingFormatted;
    self.nameLabel.text = company.name;
	
	UIColor* color; 
	
    if([company.ratingLevel intValue] == 0)
        color = [UIColor cellGreen];
    else if([company.ratingLevel intValue] == 1)
        color = [UIColor cellYellow];
    else 
        color = [UIColor cellRed];
    
	scoreBackgroundColor.backgroundColor = color;
	nameLabel.backgroundColor = color;
	
	[self layoutPartnerImageAndCompanyLabel];
    [brands viewWillAppear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(categorySelectedWithNotification:) 
                                                 name:BrandsTableCategoryButtonTouchedNotification 
                                               object:nil];
    [brands viewDidAppear:animated];
    
	
}

#pragma mark -
#pragma mark Setup


- (void)setCompany:(Company*)aCompany category:(Category*)aCategory{
	
	if(self.data==nil){
		self.data = [[[HRCBrandTableDataSource alloc] initWithCompany:aCompany category:aCategory] autorelease];
	}else{
		[data setCompany:aCompany category:aCategory];
	}
	
	self.company = aCompany;
}



- (void)layoutPartnerImageAndCompanyLabel{
	
	if(![company.partner boolValue]){
		
		self.partnerIcon.alpha = 0;
		self.nameLabel.frame = nameRectNonPartner;
		
	}else{
		
		self.partnerIcon.alpha = 1;
		self.nameLabel.frame = nameRectPartner;
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
    Category* selectedCat = (Category*)[note object];
    FilteredCompaniesViewController *detailViewController = [[FilteredCompaniesViewController alloc] initWithContext:company.managedObjectContext 
																												 key:@"categories" 
																											   value:selectedCat];
    detailViewController.view.frame = self.view.bounds;
    [self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}


#pragma mark -
#pragma mark Scorecard

- (void)showScoreCard{
    
    CompanyScoreCardViewController* vc = [[[CompanyScoreCardViewController alloc] initWithCompany:self.company] autorelease];
    [self.navigationController presentModalViewController:vc animated:YES];
    
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
		NSString* appStoreLink = [NSString stringWithFormat:rawLink, appStoreID];
		/*
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		NSString* urlPrefix = [info objectForKey:@"ScoreCardURLPrefix"];
		NSString* urlSuffix = [info objectForKey:@"ScoreCardURLSuffix"];
        NSString* companyID = [self.company.ID stringValue];
        NSString* companyScoreurl = [NSString stringWithFormat:@"%@%@%@", urlPrefix, companyID, urlSuffix];
		*/
		
		
		
        if([company.ratingLevel intValue] == 0){
            
            //GOOD
            fileName = @"EmailHappy";
            NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
            NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            emailText = [NSString stringWithFormat:fileContenets, 
                         company.name, 
                         [company.rating stringValue],
                         company.name,
                         company.name,
						 appStoreLink,
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
                         company.name,
						 appStoreLink,
                         nil
                         ];
            
            
        }else{
            
            //BAD

            if([company.rating intValue] >= 0){
                fileName = @"EmailSad";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
							 company.name, 
                             [company.rating stringValue],
                             company.name,
							 appStoreLink,
                             nil
                             ];
                
            }else {
                fileName = @"EmailConfused";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
                             company.name,
							 company.name,
							 appStoreLink,
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
#pragma mark UIActionSheet

- (void)launchActionSheet{
    
    UIActionSheet* myActionSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Help spread the word about %@", company.name] 
                                                                delegate:self 
                                                       cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"Post a Tweet", @"Send Email", nil] autorelease];
    
    
    myActionSheet.actionSheetStyle=UIActionSheetStyleAutomatic;
    [myActionSheet showFromToolbar:self.navigationController.toolbar];
    
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
            [self sendEmail];
            break;
        }
    }

}




@end

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

static CGRect nameRectPartner = {
	{10,0},
	{230,80}
};

static CGRect nameRectNonPartner = {
	{0,0},
	{240,80}
};

static CGSize nameRectMaxSize = {240,80};
static CGSize partnerImageSize = {14,14};

static CGPoint partnerImageOrigin = {2,34};

@implementation CompanyViewController

@synthesize company;
@synthesize nameLabel;
@synthesize scoreLabel;
@synthesize data;
@synthesize brands;
@synthesize scoreBackgroundColor;
@synthesize partnerIcon;

- (id)initWithCompany:(Company*)aCompany category:(Category*)aCategory{
    
    if(self = [super initWithNibName:@"CompanyViewController" bundle:nil]){
		
		[self setCompany:aCompany category:aCategory];
		
		[self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithTitle:@"Score Card" 
																			style:UIBarButtonItemStyleBordered 
																		   target:self 
																		   action:@selector(showScoreCard)]];
		
		self.toolbarItems = [NSArray arrayWithObjects: 
							 [UIBarButtonItem flexibleSpaceItem],
							 [UIBarButtonItem systemItem:UIBarButtonSystemItemAction 
												  target:self 
												  action:@selector(launchActionSheet)],
							 nil];
		
		
    }
    
    return self;
}

- (void)setCompany:(Company*)aCompany category:(Category*)aCategory{
	
	/*
	 for(Brand* eachBrand in aCompany.brands){
	 
	 NSLog(@"%@", eachBrand.nameSortFormatted);
	 
	 }
	 */		
	self.data = [[[HRCBrandTableDataSource alloc] initWithCompany:aCompany category:aCategory] autorelease];
	/*
	 NSDictionary* myData = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil];
	 NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:myData, UINibExternalObjects, nil];
	 */ 
	
	self.company = aCompany;
	
		
}


// not called when i do the loadnib thing
- (void)viewDidLoad {
    [super viewDidLoad];

    brands.data = self.data;

    if([company.ratingLevel intValue] == 0)
        scoreBackgroundColor.backgroundColor = [UIColor cellGreen];
	
    else if([company.ratingLevel intValue] == 1)
        scoreBackgroundColor.backgroundColor = [UIColor cellYellow];
	
    else 
        scoreBackgroundColor.backgroundColor = [UIColor cellRed];
    
}

- (void)viewWillDisappear:(BOOL)animated{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.scoreLabel.text = company.ratingFormatted;
    self.nameLabel.text = company.name;
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
#pragma mark Image and label Layout

- (void)layoutPartnerImageAndCompanyLabel{
	
	if(![company.partner boolValue]){
		
		self.partnerIcon.alpha = 0;
		self.nameLabel.frame = nameRectNonPartner;
		
	}else{
		
		self.partnerIcon.alpha = 1;
		CGSize nameBoundingBox = [nameLabel.text sizeWithFont:nameLabel.font
											constrainedToSize:nameLabel.frame.size
												lineBreakMode:nameLabel.lineBreakMode];
		
		if(nameBoundingBox.width > (nameRectMaxSize.width - partnerImageSize.width + 2)){
			
			//label text WILL overlap icon, resize label to compensate
			nameLabel.frame = nameRectPartner;
			
			//setting image to original position
			self.partnerIcon.frame = CGRectMake(partnerImageOrigin.x, 
												partnerImageOrigin.y, 
												partnerImageSize.width, 
												partnerImageSize.height);
			
			
		}else{
			//label text will NOT overlap icon, move icon closer to look good			
			self.partnerIcon.frame = CGRectMake(floorf((nameRectMaxSize.width - nameBoundingBox.width)/2 - partnerImageSize.width - 2), 
												partnerImageOrigin.y, 
												partnerImageSize.width, 
												partnerImageSize.height);
			
			nameLabel.frame = nameRectNonPartner;
			
			
		}
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
#pragma mark Email

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
#pragma mark UIActionSheet

- (void)launchActionSheet{
    
    UIActionSheet* myActionSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Help spread the word about %@", company.name] 
                                                                delegate:self 
                                                       cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"Send Email", nil] autorelease];
    
    
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
            [self sendEmail];
            break;
        }
    }

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

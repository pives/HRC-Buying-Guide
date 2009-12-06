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
#import "CompanyScoreCardViewController.h"

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
                    
        self.data = [[[DataSource alloc] initWithCompany:aCompany category:aCategory] autorelease];
        /*
        NSDictionary* myData = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil];
        NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:myData, UINibExternalObjects, nil];
        */ 
        
        self.company = aCompany;
        
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// not called when i do the loadnib thing
- (void)viewDidLoad {
    [super viewDidLoad];

    brands.data = self.data;

    if([company.ratingLevel intValue] == 0)
        scoreBackgroundColor.backgroundColor = [UIColor gpGreen];
    else if([company.ratingLevel intValue] == 1)
        scoreBackgroundColor.backgroundColor = [UIColor gpYellow];
    else 
        scoreBackgroundColor.backgroundColor = [UIColor gpRed];
    
    if(![company.partner boolValue])
        self.partnerIcon.alpha = 0;
    

    
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
    
    [brands viewDidAppear:animated];
    
}

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
        [controller setSubject:@"In app email..."]; //TODO: add subject
        
        NSString* fileName;
        NSString* fileExtension = @"txt";
        
        if([company.ratingLevel intValue] == 0){
            
            //GOOD
            fileName = @"EmailHappy";
        }else if([company.ratingLevel intValue] == 1){
            
            //MIDDLE
            fileName = @"EmailIndifferent";
            
        }else{
            
            //BAD
            fileName = @"EmailSad";
        }
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
        NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSString* emailText = [NSString stringWithFormat:fileContenets, company.name];
        
        
        [controller setMessageBody:emailText isHTML:NO];
        [self presentModalViewController:controller animated:YES];
        [controller release];
        
    }else{
        
        
        //TODO: display mail not configured message
        
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

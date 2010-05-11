//
//  KeyViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/20/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "KeyViewController.h"
#import "KeyWebViewController.h"


@implementation KeyViewController

@synthesize info;
@synthesize contentView;
@synthesize linkView;


- (IBAction)dismiss{
    
    [self dismissModalViewControllerAnimated:YES];
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	
	
	NSString* scheme = [[request URL] scheme];
	
	if([scheme isEqualToString:@"about"]){
		return YES;
		
	}else if([scheme isEqualToString:@"mailto"]){
		
		if([MFMailComposeViewController canSendMail]){
			
			MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
			controller.mailComposeDelegate = self;
			[controller setSubject:@"Feedback - Buying for Equality iPhone Application"];
			
			//NSString* fileName;
			//NSString* fileExtension = @"txt";
			//NSString* emailText = nil;
			
            //NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
            //NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            //emailText = [NSString stringWithFormat:fileContenets, nil];
			
			//[controller setMessageBody:emailText isHTML:YES];
			[controller setToRecipients:[NSArray arrayWithObject:@"cei@hrc.org"]];
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
		
		
	}else{
		
		KeyWebViewController* webController = [[KeyWebViewController alloc] initWithRequest:request];
		webController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:webController animated:YES];
				
	}
	
	
	return NO;
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	//TODO: Check result?
    [self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	
	NSString* html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Links" ofType:@"html"]
											   encoding:NSUTF8StringEncoding 
												  error:nil];
 	
	[linkView loadHTMLString:html baseURL:nil];
	
	[info addSubview:contentView];
    info.contentSize = contentView.frame.size;
    
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
	
	
	self.contentView = nil;
	self.linkView = nil;
	
    self.info = nil;
    [super dealloc];

}


@end

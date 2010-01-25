//
//  FJSTweetViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 1/21/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "FJSTweetViewController.h"
#import "SFHFKeychainUtils.h"
#import "FJSTwitterLoginController.h"
#import "MGTwitterEngine.h"
#import "Company.h"
#import "NSError+Alertview.h"
#import "LoadingView.h"

@interface FJSTweetViewController()

@property(nonatomic,retain)MGTwitterEngine *twitterEngine;
@property(nonatomic,copy)NSString *prefilledText;

- (void)launchLoginView;

@end


@implementation FJSTweetViewController

@synthesize tweetTextView;
@synthesize charCount;
@synthesize twitterEngine;
@synthesize prefilledText;
@synthesize accountName;


#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.accountName = nil;
	self.prefilledText = nil;
	self.tweetTextView = nil;
	self.charCount = nil;
	self.twitterEngine = nil;
    [super dealloc];
}


- (id)initWithText:(NSString*)someText{
	
	self = [super initWithNibName:@"FJSTweetViewController" bundle:nil];
	if (self != nil) {
		
		self.prefilledText = someText;
		
	}
	return self;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didLoginWithNotification:) 
												 name:FJSTwitterLoginSuccessful 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didNotLoginWithNotification:) 
												 name:FJSTwitterLoginUnsuccessful 
											   object:nil];	
	
	
	self.tweetTextView.font = [UIFont systemFontOfSize:14];
	self.tweetTextView.text = self.prefilledText;
	
	self.twitterEngine = [MGTwitterEngine twitterEngineWithDelegate:self];

	
}

- (void)viewWillAppear:(BOOL)animated{
	
	NSString* username = [self.twitterEngine username];

	if(username == nil)
		username = [[NSUserDefaults standardUserDefaults] objectForKey:FJSTwitterUsernameKey];
	
	[self.accountName setTitle:username forState:UIControlStateNormal];

}

- (void)viewDidAppear:(BOOL)animated{
	
	//Check the twitter engine to see if credentials are already supplied
	NSString* username = [self.twitterEngine username];
	NSString* password = [self.twitterEngine password];
	
	if(username!=nil && password!=nil)
		return;
		
	
	//lets get credentials from user defaults and the keychain
	username = [[NSUserDefaults standardUserDefaults] objectForKey:FJSTwitterUsernameKey];
	
	NSError* error = nil;
	password = [SFHFKeychainUtils getPasswordForUsername:username 
										  andServiceName:FJSTwitterServiceName 
												   error:&error];
	
	
	if(username==nil || password==nil){
		[self performSelector:@selector(launchLoginView) withObject:nil afterDelay:0.2];
		return;
	}

	[self.twitterEngine setUsername:username password:password];
	[self.tweetTextView becomeFirstResponder];

}

#pragma mark -
#pragma mark IBActions

- (IBAction)tweet{
	
	int maxChars = 140;
	
	if(self.tweetTextView.text.length > maxChars){
		
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No more characters"
														 message:[NSString stringWithFormat:@"You have reached the character limit of %d.",maxChars]
														delegate:nil
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	CGRect rect = self.view.bounds;
	rect.size.height = rect.size.height - 215;
	
	[[LoadingView loadingViewInView:self.view frame:rect] setDelegate:self];
	
	[self.twitterEngine sendUpdate:self.tweetTextView.text];	
}

- (IBAction)cancel{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)login{
	
	[self launchLoginView];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	[self tweet];	
	return NO;
}

- (void)textViewDidChange:(UITextView *)textView{
	
	int maxChars = 140;
	int charsLeft = maxChars - [textView.text length];
	
	self.charCount.text = [NSString stringWithFormat:@"%d",charsLeft];
	
}


#pragma mark -
#pragma mark FJSTwitterLoginController

- (void)launchLoginView{
	
	FJSTwitterLoginController* tvc = [[[FJSTwitterLoginController alloc] init] autorelease];
	
	tvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:tvc animated:YES];
	
}

#pragma mark -
#pragma mark FJSTwitterLoginController Notifications

- (void)didLoginWithNotification:(NSNotification*)note{
	
	NSDictionary* userInfo = [note userInfo];
	
	NSString* username = [userInfo objectForKey:FJSTwitterUsernameKey];
	NSString* password = [userInfo objectForKey:FJSTwitterPasswordKey];
	
	[self.twitterEngine setUsername:username password:password];
}

- (void)didNotLoginWithNotification:(NSNotification*)note{
	
	//not so fancy trick to get the the tweet view and login view to dismiss in one animation
	self.modalViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
	
}


#pragma mark -
#pragma mark MGTwitterEngineDelegate

- (void)requestSucceeded:(NSString *)connectionIdentifier{
		
	
	for(UIView* aView in self.view.subviews){
		
		if([aView isKindOfClass:[LoadingView class]])
			[(LoadingView*)aView updateTextAndRemoveView:@"Tweet Sent!"];
	}
}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error{
	
	for(UIView* aView in self.view.subviews){
		
		if([aView isKindOfClass:[LoadingView class]])
			[(LoadingView*)aView removeView];
	}
	
	[error presentAlertViewWithDelegate:nil];	
}


- (void)loadingViewDidClose:(LoadingView*)loadingView{
	[self dismissModalViewControllerAnimated:YES];
}



@end

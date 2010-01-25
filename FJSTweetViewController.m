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


#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
	
	
	self.tweetTextView.text = self.prefilledText;
	
	self.twitterEngine = [MGTwitterEngine twitterEngineWithDelegate:self];

	
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

}

#pragma mark -
#pragma mark IBActions

- (IBAction)tweet{
	[self.twitterEngine sendUpdate:self.tweetTextView.text];	
}

- (IBAction)cancel{
	[self dismissModalViewControllerAnimated:YES];
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
		
	//TODO: display success
	//[self dismissModalViewControllerAnimated:YES];
}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error{
	
	[error presentAlertViewWithDelegate:nil];	
}




@end

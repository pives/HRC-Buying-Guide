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

@implementation FJSTweetViewController

@synthesize tweetTextView;
@synthesize charCount;
@synthesize twitterEngine;


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.tweetTextView = nil;
	self.charCount = nil;
	self.twitterEngine = nil;
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginWithNotification:) name:FJSTwitterLoginSuccessful object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotLoginWithNotification:) name:FJSTwitterLoginUnsuccessful object:nil];	
	
	
	self.twitterEngine = [MGTwitterEngine twitterEngineWithDelegate:self];
	
	NSString* twitterName = [[NSUserDefaults standardUserDefaults] objectForKey:FJSTwitterUsernameKey];
	
	if(twitterName == nil){
		
		[self launchLoginView];
		
	}else{
		
		NSError* error = nil;
		NSString* password = [SFHFKeychainUtils getPasswordForUsername:twitterName 
														andServiceName:FJSTwitterServiceName 
																 error:&error];
		if(error!=nil){
			
			//can't get a password oh well, should be nil.
			
		}
		
		if(password != nil){
			
			[self.twitterEngine setUsername:twitterName password:password];
			
		}else{
			
			[self launchLoginView];
			
		}
	}
}


- (IBAction)tweet{
	
	//TODO: post
	
}

- (IBAction)cancel{
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)launchLoginView{
	
		
	FJSTwitterLoginController* tvc = [[FJSTwitterLoginController alloc] initWithTwitterEngine:self.twitterEngine];
	tvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:tvc animated:YES];
	[tvc release];
}

- (void)didLoginWithNotification:(NSNotification*)note{
	
	//TODO: do I care?
}

- (void)didNotLoginWithNotification:(NSNotification*)note{
	
	[self cancel];
	
}


@end

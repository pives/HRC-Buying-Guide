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
	self.tweetTextView = nil;
	self.charCount = nil;
	self.twitterEngine = nil;
    [super dealloc];
}


- (IBAction)tweet{
	
	//TODO: post
	
}

- (IBAction)cancel{
	
	[self dismissModalViewControllerAnimated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
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

- (void)launchLoginView{
	
	FJSTwitterLoginController* tvc = [[FJSTwitterLoginController alloc] initWithTwitterEngine:self.twitterEngine];
	tvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:tvc animated:YES];
	[tvc release];
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


@end

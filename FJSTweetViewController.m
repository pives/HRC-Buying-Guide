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


@interface FJSTweetViewController()

@property(nonatomic,retain)Company *company;
@property(nonatomic,retain)MGTwitterEngine *twitterEngine;

- (void)launchLoginView;

@end


@implementation FJSTweetViewController

@synthesize tweetTextView;
@synthesize charCount;
@synthesize twitterEngine;
@synthesize company;




- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.company = nil;
	self.tweetTextView = nil;
	self.charCount = nil;
	self.twitterEngine = nil;
    [super dealloc];
}


- (id)initWithCompany:(Company*)aCompany{
	
	self = [super initWithNibName:@"FJSTweetViewController" bundle:nil];
	if (self != nil) {
		
		self.company = aCompany;
		
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
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
	
	
	
	NSMutableString* initialtext = [NSMutableString string];
	[initialtext appendString:@"@HRC "];
	[initialtext appendString:self.company.name];
	self.tweetTextView.text = initialtext;

	
	self.twitterEngine = [MGTwitterEngine twitterEngineWithDelegate:self];
	
	}

- (void)viewDidAppear:(BOOL)animated{
	
	NSString* twitterName = [[NSUserDefaults standardUserDefaults] objectForKey:FJSTwitterUsernameKey];
	
	if(twitterName == nil){
		
		[self performSelector:@selector(launchLoginView) withObject:nil afterDelay:0.2];
		
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
			
			[self performSelector:@selector(launchLoginView) withObject:nil afterDelay:0.2];
			
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
	
	
	FJSTwitterLoginController* tvc = [[[FJSTwitterLoginController alloc] initWithTwitterEngine:self.twitterEngine] autorelease];
	
	tvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:tvc animated:YES];
	
}

- (void)didLoginWithNotification:(NSNotification*)note{
	
	//TODO: do I care?
}

- (void)didNotLoginWithNotification:(NSNotification*)note{
	
	[self cancel];
	
}


@end

//
//  FJSTwitterLoginController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 1/21/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "FJSTwitterLoginController.h"
#import "NSString+extensions.h"
#import "UIAlertViewHelper.h"
#import "MGTwitterEngine.h"
#import "SFHFKeychainUtils.h"
#import "NSError+Alertview.h"

NSString* const FJSTwitterLoginSuccessful = @"FJSTwitterLoginSuccessful";
NSString* const FJSTwitterLoginUnsuccessful = @"FJSTwitterLoginUnsuccessful";

NSString* const FJSTwitterUsernameKey = @"FJSTwitterUsername";
NSString* const FJSTwitterServiceName = @"FJSTwitterKeychainServiceName";

@implementation FJSTwitterLoginController


@synthesize username;
@synthesize password;
@synthesize passwordCheckBox;
@synthesize twitterEngine;


- (void)dealloc {
	self.twitterEngine = nil;
	self.passwordCheckBox = nil;
	self.username = nil;
	self.password = nil;
    [super dealloc];
}

- (id)initWithTwitterEngine:(MGTwitterEngine*)engine{
	self = [super initWithNibName:@"FJSTwitterLoginController" bundle:nil];
	if (self != nil) {		
		self.twitterEngine = engine;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
}


- (void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self.username becomeFirstResponder];
	
}


- (IBAction)login{
	
	if(password.text == nil || [password.text isEmpty])
		return;
	if(username.text == nil || [username.text isEmpty])
		return;
	
	[[NSUserDefaults standardUserDefaults] setObject:self.username.text forKey:FJSTwitterUsernameKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.twitterEngine setUsername:username.text password:password.text];
	
	[self.twitterEngine checkUserCredentials];
				
}


- (IBAction)togglePasswordSaving:(id)sender{
	
	UIButton* save = (UIButton*)sender;
	
	save.selected = !save.selected;
	
}

- (IBAction)cancel{
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FJSTwitterLoginUnsuccessful object:self];

	//Might not need
	//[self dismissModalViewControllerAnimated:YES];
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	if(textField == self.username){
		
		[self.password becomeFirstResponder];
		
	}else{
		
		[self login];
	}
	
	return NO;
}

- (void)saveUserCredentials{
	
	if([self.passwordCheckBox state] != UIControlStateSelected)
		return;
	
	NSError* error = nil;
	[SFHFKeychainUtils storeUsername:self.username.text 
						 andPassword:self.password.text 
					  forServiceName:FJSTwitterServiceName 
					  updateExisting:YES 
							   error:&error];
	
	
	if(error!=nil){
		
		//TODO: wtf, couldn't save
	}
	
}

- (void)requestSucceeded:(NSString *)connectionIdentifier{

	[self saveUserCredentials];	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FJSTwitterLoginSuccessful object:self];
	
	[self dismissModalViewControllerAnimated:YES];
}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error{
	
	if([error code] == -1009)
		[UIAlertView presentNoInternetAlertWithDelegate:nil];
	else 
		[error presentAlertViewWithDelegate:nil];
	
}



@end

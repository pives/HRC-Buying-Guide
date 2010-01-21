//
//  FJSTwitterLoginController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 1/21/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "FJSTwitterLoginController.h"
#import "NSString+extensions.h"

NSString* const FJSTwitterLoginSuccessful = @"FJSTwitterLoginSuccessful";
NSString* const FJSTwitterLoginUnsuccessful = @"FJSTwitterLoginUnsuccessful";

@implementation FJSTwitterLoginController


@synthesize username;
@synthesize password;
@synthesize passwordCheckBox;


- (void)dealloc {
	self.passwordCheckBox = nil;
	self.username = nil;
	self.password = nil;
    [super dealloc];
}


- (void)viewDidLoad {
	[super viewDidLoad];
}



- (IBAction)login{
	
	if(password.text == nil || [password.text isEmpty])
		return;
	if(username.text == nil || [username.text isEmpty])
		return;
	
	//TODO: login
	
	[self saveUserCredentials];
		
}


- (IBAction)togglePasswordSaving:(id)sender{
	
	UIButton* save = (UIButton*)sender;
	
	save.selected = !save.selected;
	
}

- (IBAction)cancel{
	
	[self dismissModalViewControllerAnimated:YES];
	
}

- (void)saveUserCredentials{
	
	if([self.passwordCheckBox state] != UIControlStateSelected)
		return;
	
	//TODO: save login. Use keychain?
	
}



@end

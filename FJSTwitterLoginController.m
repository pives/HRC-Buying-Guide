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
#import "LoadingView.h"

NSString* const FJSTwitterLoginSuccessful = @"FJSTwitterLoginSuccessful";
NSString* const FJSTwitterLoginUnsuccessful = @"FJSTwitterLoginUnsuccessful";

NSString* const FJSTwitterUsernameKey = @"FJSTwitterUsername";
NSString* const FJSTwitterPasswordKey = @"FJSTwitterPassord";

NSString* const FJSTwitterServiceName = @"FJSTwitterKeychainServiceName";


@interface FJSTwitterLoginController()

@property(nonatomic,retain)MGTwitterEngine *twitterEngine;

- (void)saveUserCredentials;

@end

@implementation FJSTwitterLoginController


@synthesize username;
@synthesize password;
@synthesize passwordCheckBox;
@synthesize twitterEngine;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	self.twitterEngine = nil;
	self.passwordCheckBox = nil;
	self.username = nil;
	self.password = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
}


- (void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	self.username.text = [[NSUserDefaults standardUserDefaults] objectForKey:FJSTwitterUsernameKey];
	[self.username becomeFirstResponder];
	
}

#pragma mark -
#pragma mark IBActions

- (IBAction)login{
	
	if(password.text == nil || [password.text isEmpty])
		return;
	if(username.text == nil || [username.text isEmpty])
		return;
	
	[[NSUserDefaults standardUserDefaults] setObject:self.username.text forKey:FJSTwitterUsernameKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	self.twitterEngine = [MGTwitterEngine twitterEngineWithDelegate:self];
	[self.twitterEngine setUsername:username.text password:password.text];
	
	CGRect rect = self.view.bounds;
	rect.size.height = rect.size.height - 215;
	
	[[LoadingView loadingViewInView:self.view frame:rect] setDelegate:self];
	
	[self.twitterEngine checkUserCredentials];
				
}


- (IBAction)togglePasswordSaving:(id)sender{
	
	UIButton* save = (UIButton*)sender;
	
	save.selected = !save.selected;
	
}

- (IBAction)cancel{
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FJSTwitterLoginUnsuccessful object:self];
	
}

#pragma mark -
#pragma mark SFHFKeychainUtils

- (void)saveUserCredentials{
	
	NSError* error = nil;

	if([self.passwordCheckBox state] != UIControlStateSelected){
		
		[SFHFKeychainUtils deleteItemForUsername:self.username.text 
								  andServiceName:FJSTwitterServiceName 
										   error:&error];
		
	}else{
		
		[SFHFKeychainUtils storeUsername:self.username.text 
							 andPassword:self.password.text 
						  forServiceName:FJSTwitterServiceName 
						  updateExisting:YES 
								   error:&error];
		
	}
	
	if(error!=nil){
		
		//wtf, couldn't save or delete, oh well
	}
	
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	if(textField == self.username){
		
		[self.password becomeFirstResponder];
		
	}else{
		
		[self login];
	}
	
	return NO;
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate

- (void)requestSucceeded:(NSString *)connectionIdentifier{

	for(UIView* aView in self.view.subviews){
		
		if([aView isKindOfClass:[LoadingView class]])
			[(LoadingView*)aView updateTextAndRemoveView:@"Success!"];
	}
	
	[self saveUserCredentials];	
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  username.text, 
							  FJSTwitterUsernameKey, 
							  password.text, 
							  FJSTwitterPasswordKey, 
							  nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FJSTwitterLoginSuccessful 
														object:self 
													  userInfo:userInfo];
	
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

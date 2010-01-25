//
//  FJSTwitterLoginController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 1/21/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGTwitterEngine;

@interface FJSTwitterLoginController : UIViewController <UITextFieldDelegate> {
	
	UITextField* username;
	UITextField* password;
	UIButton* passwordCheckBox;
	
	MGTwitterEngine* twitterEngine;
}
@property(nonatomic,assign)IBOutlet UITextField *username;
@property(nonatomic,assign)IBOutlet UITextField *password;
@property(nonatomic,retain)IBOutlet UIButton *passwordCheckBox;


//Actions, not for You!
- (IBAction)login;
- (IBAction)togglePasswordSaving:(id)sender;
- (IBAction)cancel;


@end

//Notifications

//called when login successful, account info in userInfo dictionary
extern NSString* const FJSTwitterLoginSuccessful;

//only called if the user gives up, not posted for each unsuccessful login attempt
extern NSString* const FJSTwitterLoginUnsuccessful;

//Userinfo Dictionary Keys
extern NSString* const FJSTwitterUsernameKey; //Check the user defualts for this key before launching
extern NSString* const FJSTwitterPasswordKey;

//Use this service name with the username to retrieve the password from the keychain (Using SFHFKeychainUtils)
extern NSString* const FJSTwitterServiceName;

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
@property(nonatomic,retain)MGTwitterEngine *twitterEngine;

- (id)initWithTwitterEngine:(MGTwitterEngine*)engine;

//Actions, not for You!
- (IBAction)login;
- (IBAction)togglePasswordSaving:(id)sender;
- (IBAction)cancel;


@end


extern NSString* const FJSTwitterLoginSuccessful;
extern NSString* const FJSTwitterLoginUnsuccessful;

extern NSString* const FJSTwitterUsernameKey;
extern NSString* const FJSTwitterServiceName;

//
//  FJSTwitterLoginController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 1/21/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FJSTwitterLoginController : UIViewController {
	
	UITextField* username;
	UITextField* password;

	UIButton* passwordCheckBox;
}
@property(nonatomic,assign)IBOutlet UITextField *username;
@property(nonatomic,assign)IBOutlet UITextField *password;
@property(nonatomic,retain)IBOutlet UIButton *passwordCheckBox;

- (IBAction)login;
- (IBAction)togglePasswordSaving;
- (IBAction)cancel;

@end


extern NSString* const FJSTwitterLoginSuccessful;
extern NSString* const FJSTwitterLoginUnsuccessful;
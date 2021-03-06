//
//  UIAlertViewHelper.m
//  CocoaHelpers
//
//  Created by Shaun Harrison on 10/16/08.
//  Copyright 2008 enormego. All rights reserved.
//

#import "UIAlertViewHelper.h"
#import "NSString+extensions.h"

void UIAlertViewQuick(NSString* title, NSString* message, NSString* dismissButtonTitle) {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LocalizedString(title) 
													message:LocalizedString(message) 
												   delegate:nil 
										  cancelButtonTitle:LocalizedString(dismissButtonTitle) 
										  otherButtonTitles:nil
						  ];
	[alert show];
	[alert autorelease];
}


@implementation UIAlertView (Helper)

+ (id)presentAlertViewWithTitle:(NSString*)aTitle message:(NSString*)aMessage delegate:(id)object{
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:aTitle
													message:aMessage
												   delegate:object 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil
						  ];
	[alert show];
	return [alert autorelease];
	
}

+ (id)presentNoInternetAlertWithDelegate:(id)object{
	

	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Could not connect to Twitter"
													  message:@"Could not connect to the internet. Please ensure your Wifi or 3G is turned on and try again."
													 delegate:object 
											cancelButtonTitle:@"OK" 
											otherButtonTitles:nil];
	[alert show];
	return [alert autorelease];
	
	
}

+ (id)presentIncorrectPasswordAlertWithDelegate:(id)object{
	

	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Could not authenticate"
													message:@"Please check your username and password and try again."
												   delegate:object 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	return [alert autorelease];
	
}

@end

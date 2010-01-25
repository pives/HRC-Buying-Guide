//
//  FJSTweetViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 1/21/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGTwitterEngine;
@class Company;

@interface FJSTweetViewController : UIViewController {

	UITextView* tweetTextView;
	UILabel* charCount;
	UIButton* accountName;
	
	NSString* prefilledText;
	MGTwitterEngine* twitterEngine;
	
}
@property(nonatomic,retain)IBOutlet UITextView *tweetTextView;
@property(nonatomic,retain)IBOutlet UILabel *charCount;
@property(nonatomic,retain)IBOutlet UIButton *accountName;


- (id)initWithText:(NSString*)someText;

//Don't you touch me!
- (IBAction)tweet;
- (IBAction)cancel;
- (IBAction)login;

@end

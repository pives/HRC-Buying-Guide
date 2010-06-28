//
//  FJSTweetViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 1/21/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;
@class BGCompany;

@interface FJSTweetViewController : UIViewController <SA_OAuthTwitterControllerDelegate> {

	UITextView* tweetTextView;
	UILabel* charCount;
	UIButton* accountName;
    UIBarButtonItem* sendButton;
    
	NSString* prefilledText;
	SA_OAuthTwitterEngine* twitterEngine;
    
    BOOL canceled;
	
}
@property(nonatomic,retain)IBOutlet UITextView *tweetTextView;
@property(nonatomic,retain)IBOutlet UILabel *charCount;
@property(nonatomic,retain)IBOutlet UIButton *accountName;
@property(nonatomic,retain)IBOutlet UIBarButtonItem *sendButton;
@property(nonatomic,assign)BOOL canceled;


- (id)initWithText:(NSString*)someText;

//Don't you touch me!
- (IBAction)tweet;
- (IBAction)cancel;
- (IBAction)loginManually;

@end

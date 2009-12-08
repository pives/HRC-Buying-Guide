//
//  KeyViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/20/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface KeyViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
    
    UIScrollView* info;
	UIView* contentView;
	UIWebView* linkView;

}
@property(nonatomic,assign)IBOutlet UIScrollView *info;
@property(nonatomic,retain)IBOutlet UIView *contentView;
@property(nonatomic,assign)IBOutlet UIWebView *linkView;

- (IBAction)dismiss;

@end

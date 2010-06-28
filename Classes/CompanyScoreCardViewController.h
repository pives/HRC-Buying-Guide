//
//  CompanyScoreCardViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGCompany;

@interface CompanyScoreCardViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>{

    UIToolbar* bar;
    UIActivityIndicatorView* spinner;
    UIWebView* card;
    NSURL* address;
}
@property(nonatomic,assign)IBOutlet UIToolbar *bar;
@property(nonatomic,retain)UIActivityIndicatorView *spinner;
@property(nonatomic,assign)IBOutlet UIWebView *card;
@property(nonatomic,retain)NSURL *address;

- (id)initWithCompany:(BGCompany*)aCompany;
- (IBAction)done;

@end

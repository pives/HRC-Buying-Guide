//
//  CompanyScoreCardViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGCompany;

@interface KeyWebViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>{

    UIToolbar* bar;
    UIActivityIndicatorView* spinner;
    UIWebView* webview;
    NSURLRequest* request;
}
@property(nonatomic,assign)IBOutlet UIToolbar *bar;
@property(nonatomic,retain)UIActivityIndicatorView *spinner;
@property(nonatomic,assign)IBOutlet UIWebView *webview;
@property(nonatomic,retain)NSURLRequest *request;

- (id)initWithRequest:(NSURLRequest*)aRequest;
- (IBAction)done;

@end

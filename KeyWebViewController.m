//
//  CompanyScoreCardViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "KeyWebViewController.h"
#import "Company.h"
#import "NSString+extensions.h"
#import "UIBarButtonItem+extensions.h"

@implementation KeyWebViewController

@synthesize bar;
@synthesize spinner;
@synthesize webview;
@synthesize request;


- (void)dealloc {
    self.spinner = nil;
	self.webview = nil;
	self.request = nil;
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (id)initWithRequest:(NSURLRequest*)aRequest
{
    self = [super initWithNibName:@"KeyWebView" bundle:nil];
    if (self != nil) {
        
		self.request = aRequest;        
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    NSMutableArray* items = [bar.items mutableCopy];
        
    [items insertObject:[UIBarButtonItem fixedSpaceItemOfSize:12]  atIndex:0];
    [items insertObject:[UIBarButtonItem itemWithView:self.spinner] atIndex:0];
    
    bar.items = items;
    [items release];
    
    [webview loadRequest:self.request];
                        
}

- (void)viewWillAppear:(BOOL)animated{
    
    [spinner startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [spinner stopAnimating];
    
}
                        

- (IBAction)done{
    
    [self dismissModalViewControllerAnimated:YES];
}


@end

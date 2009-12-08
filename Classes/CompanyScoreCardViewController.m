//
//  CompanyScoreCardViewController.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "CompanyScoreCardViewController.h"
#import "Company.h"
#import "NSString+extensions.h"
#import "UIBarButtonItem+extensions.h"

@implementation CompanyScoreCardViewController

@synthesize bar;
@synthesize spinner;
@synthesize card;
@synthesize address;


- (void)dealloc {
    self.spinner = nil;
    self.address = nil;
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (id)initWithCompany:(Company*)aCompany
{
    self = [super initWithNibName:@"CompanyScoreCardView" bundle:nil];
    if (self != nil) {
        
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		NSString* urlPrefix = [info objectForKey:@"ScoreCardURLPrefix"];
		NSString* urlSuffix = [info objectForKey:@"ScoreCardURLSuffix"];
        NSString* companyID = [aCompany.ID stringValue];
        NSString* url = [NSString stringWithFormat:@"%@%@%@", urlPrefix, companyID, urlSuffix];
        self.address = [NSURL URLWithString:url];
        
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
    
    [card loadRequest:[NSURLRequest requestWithURL:address]];
                        
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

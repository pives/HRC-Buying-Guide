//
//  PageViewController.m
//  PagingScrollView
//
//  Created by Matt Gallagher on 24/01/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "PageViewController.h"
#import "HRCBrandTableDataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "Company.h"
#import "Company+Extensions.h"
#import "UIColor+extensions.h"
#import "HRCBrandTableViewController.h"
#import "NSString+extensions.h"

const CGFloat TEXT_VIEW_PADDING = 50.0;

@implementation PageViewController

@synthesize pageIndex;
@synthesize data;
@synthesize company;
@synthesize category;
@synthesize categoryName;
@synthesize ratingColor;
@synthesize tableController;

@synthesize managedObjectContext;


#pragma mark -
#pragma mark Memory management

- (void) dealloc
{
    self.ratingColor = nil;    
    self.categoryName = nil;
    self.company = nil;
    self.category = nil;
    self.data = nil;
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
	if([keyPath isEqualToString:@"data"]){
		
		self.company = data.company;
		self.managedObjectContext = company.managedObjectContext;
		
		if([company.ratingLevel intValue] == 0)
			self.ratingColor = [UIColor cellGreen];
		else if([company.ratingLevel intValue] == 1)
			self.ratingColor = [UIColor cellYellow];
		else 
			self.ratingColor = [UIColor cellRed];
		
		[self.tableController setCompany:self.company category:self.category color:self.ratingColor];
	}
}

- (id)initWithDataSource:(HRCBrandTableDataSource*)someData{
    
    if(self = [super init]){
        
		[self addObserver:self forKeyPath:@"data" options:0 context:nil];
		self.data = someData;
    }
    return self;
}


- (void)viewWillDisappear:(BOOL)animated{
	
	FJSLog([NSString stringWithInt:self.pageIndex]);

}

- (void)viewDidDisappear:(BOOL)animated{
	
	FJSLog([NSString stringWithInt:self.pageIndex]);

}


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    if(self.tableController == nil){
        self.tableController = [[[HRCBrandTableViewController alloc] initWithStyle:UITableViewStylePlain 
                                                                       company:self.company 
                                                                      category:self.category
                                                                         color:self.ratingColor] autorelease];
        
        tableController.tableFrame = CGRectMake(0, 44, 320, 236-25);
        self.categoryName.font = [UIFont boldSystemFontOfSize:15];
		
		[self.tableController setCompany:self.company category:self.category color:self.ratingColor];
        [self.view addSubview:tableController.view];
		

        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
	
	//FJSLog([NSString stringWithInt:self.pageIndex]);
	
    //[self.tableController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
	
	FJSLog([NSString stringWithInt:self.pageIndex]);

}

- (void)setPageIndex:(NSInteger)newPageIndex
{
	
	pageIndex = newPageIndex;
    
	if (pageIndex >= 0 && pageIndex < ([data numDataPages]))
	{
        
        if(pageIndex == 0){
                        
            self.category = nil;
            self.categoryName.text = @"All Brands";
            tableController.category = nil;
			tableController.tableView.tableFooterView.alpha = 0;
            
        }else{
            
            self.category = [company.categoriesSortedAlphabetically objectAtIndex:(pageIndex-1)];     
            self.categoryName.text = self.category.nameDisplayFriendly;
            tableController.category = [company.categoriesSortedAlphabetically objectAtIndex:(pageIndex-1)];
			tableController.tableView.tableFooterView.alpha = 1;

        }
        
		[tableController viewWillAppear:YES];
		
        //[tableController fetch];
    }
}
@end


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
#import "DataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "Company.h"
#import "Company+Extensions.h"
#import "UIColor+extensions.h"
#import "PageTableViewController.h"

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

- (id)initWithDataSource:(DataSource*)someData{
    
    if(self = [super init]){
        
        self.data = someData;
        self.company = data.company;
        self.managedObjectContext = company.managedObjectContext;
        
        if([company.ratingLevel intValue] == 0)
            self.ratingColor = [UIColor gpGreen];
        else if([company.ratingLevel intValue] == 1)
            self.ratingColor = [UIColor gpYellow];
        else 
            self.ratingColor = [UIColor gpRed];

    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    if(self.tableController == nil){
        self.tableController = [[[PageTableViewController alloc] initWithStyle:UITableViewStylePlain 
                                                                       company:self.company 
                                                                      category:self.category
                                                                         color:self.ratingColor] autorelease];
        
        tableController.tableFrame = CGRectMake(0, 44, 320, 236-25);
        self.categoryName.font = [UIFont boldSystemFontOfSize:15];
        [self.view addSubview:tableController.view];
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.tableController viewWillAppear:animated];
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
            
        }else{
            
            self.category = [company.categoriesSortedAlphabetically objectAtIndex:(pageIndex-1)];     
            self.categoryName.text = self.category.name;
            tableController.category = [company.categoriesSortedAlphabetically objectAtIndex:(pageIndex-1)];
        }
        
        [tableController fetch];
    }
}
@end


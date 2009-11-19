//
//  PagingScrollViewController.m
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

#import "PagingScrollViewController.h"
#import "PageViewController.h"
#import "DataSource.h"

@implementation PagingScrollViewController

@synthesize data;

- (void)applyNewIndex:(NSInteger)newIndex pageController:(PageViewController *)pageController
{
	NSInteger pageCount = [self.data numDataPages];
	BOOL outOfBounds = newIndex >= pageCount || newIndex < 0;

	if (!outOfBounds)
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = 0;
		pageFrame.origin.x = scrollView.frame.size.width * newIndex;
		pageController.view.frame = pageFrame;
	}
	else
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = scrollView.frame.size.height;
		pageController.view.frame = pageFrame;
	}

	pageController.pageIndex = newIndex;
}


- (void)viewDidLoad
{
	currentPage = [[[PageViewController alloc] initWithDataSource:self.data] retain];
	nextPage = [[[PageViewController alloc] initWithDataSource:self.data] retain];
    currentPage.view.frame = self.view.bounds;
    nextPage.view.frame = self.view.bounds;
	[scrollView addSubview:currentPage.view];
	[scrollView addSubview:nextPage.view];

	NSInteger widthCount = [self.data numDataPages];
	if (widthCount == 0)
	{
		widthCount = 1;
	}
	
    scrollView.contentSize =
		CGSizeMake(
			scrollView.frame.size.width * widthCount,
			scrollView.frame.size.height);
	scrollView.contentOffset = CGPointMake(0, 0);

	pageControl.numberOfPages = ([self.data numDataPages]); 
    
    //pageControl.currentPage = 0     
    
    [self changePageUnanianimated:[data pageOfStartingSelectedCategory]];
    /*
	pageControl.currentPage = 0;
	
	[self applyNewIndex:0 pageController:currentPage];
	[self applyNewIndex:1 pageController:nextPage];
     */
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
	
	if (lowerNumber == currentPage.pageIndex)
	{
		if (upperNumber != nextPage.pageIndex)
		{
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	else if (upperNumber == currentPage.pageIndex)
	{
		if (lowerNumber != nextPage.pageIndex)
		{
			[self applyNewIndex:lowerNumber pageController:nextPage];
		}
	}
	else
	{
		if (lowerNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:upperNumber pageController:currentPage];
		}
		else if (upperNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
		}
		else
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	
    //TODO: cells set need display
    //TODO: may need to send update message to tableview

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)newScrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);

	if (currentPage.pageIndex != nearestNumber)
	{
		PageViewController *swapController = currentPage;
		currentPage = nextPage;
		nextPage = swapController;
	}

    //TODO: may need to send update message to tableview
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)newScrollView
{
	[self scrollViewDidEndScrollingAnimation:newScrollView];
	pageControl.currentPage = currentPage.pageIndex;
}

- (IBAction)changePage:(id)sender
{
	NSInteger pageIndex = pageControl.currentPage;

	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageIndex;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
}

- (void)changePageUnanianimated:(int)pageIndex
{
	pageControl.currentPage = pageIndex;
    [self applyNewIndex:pageIndex pageController:currentPage];
    
    if(pageIndex==0){
        [self applyNewIndex:pageIndex+1 pageController:nextPage];

    }else{
        
        [self applyNewIndex:pageIndex-1 pageController:nextPage];
        
        // update the scroll view to the appropriate page
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * pageIndex;
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:NO];

    }
}

- (void)dealloc
{

    self.data = nil;
	[currentPage release];
	[nextPage release];
	
	[super dealloc];
}

@end

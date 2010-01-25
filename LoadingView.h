//
//  LoadingView.h
//  LoadingView
//
//  Created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Use of this file is subject to the MIT-style license in the license.txt
//  file included with the project.
//

#import <UIKit/UIKit.h>

@class LoadingView;

@protocol LoadingViewDelegate <NSObject>

- (void)loadingViewDidClose:(LoadingView*)loadingView;

@end




@interface LoadingView : UIView{

    id<LoadingViewDelegate> delegate;
}
@property(nonatomic,retain)id<LoadingViewDelegate> delegate;

//loadingview is the same size as the superview
+ (id)loadingViewInView:(UIView *)aSuperview withText:(NSString*)text;
+ (id)loadingViewInView:(UIView *)aSuperview;

//loadingview is bounded by the given rect within the superview
+ (id)loadingViewInView:(UIView *)aSuperview frame:(CGRect)rect withText:(NSString*)text;
+ (id)loadingViewInView:(UIView *)aSuperview frame:(CGRect)rect;


//update the loading view
- (void)updateText:(NSString *)text;
- (void)startActivity;
- (void)stopActivity;



//fade out animation
- (void)removeView;

//updates text then fades out view after a brief pause
- (void)updateTextAndRemoveView:(NSString *)text;


@end

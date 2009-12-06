//
//  FJSTableViewColorIndex.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/4/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol FJSTableViewImageIndexDelegate;

@interface FJSTableViewImageIndex : UIView {
    
    UIImageView* slider;
    int numberOfSections;
    id <FJSTableViewImageIndexDelegate> delegate;
    int currentlyTouchedSegment;
    
    CALayer* overlay;

}
@property(nonatomic,retain) UIImageView *slider;
@property(nonatomic,assign)int numberOfSections;
@property(nonatomic,assign)id <FJSTableViewImageIndexDelegate> delegate;
@property(nonatomic,assign)int currentlyTouchedSegment;
@property(nonatomic,retain)CALayer *overlay;

- (id)initWithFrame:(CGRect)rect image:(UIImage*)anImage sections:(int)sections;


@end




@protocol FJSTableViewImageIndexDelegate <NSObject>

@optional
- (void)didTouchSegment:(int)segment inColorIndex:(FJSTableViewImageIndex*)index;

@end

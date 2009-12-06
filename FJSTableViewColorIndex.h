//
//  FJSTableViewColorIndex.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/4/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol FJSTableViewColorIndexDelegate;



//TODO: bring over code from image index
//TODO: create an image and cache it, so it doesn't take so long.
//TODO: possibly save image to disk to allow all instances of the class to use it

@interface FJSTableViewColorIndex : UIView {
    
    NSArray* colors;
    id <FJSTableViewColorIndexDelegate> delegate;
    int currentlyTouchedSegment;
    
    CALayer* overlay;

}
@property(nonatomic,retain)NSArray *colors;
@property(nonatomic,assign)id <FJSTableViewColorIndexDelegate> delegate;
@property(nonatomic,assign)int currentlyTouchedSegment;
@property(nonatomic,retain)CALayer *overlay;

- (id)initWithFrame:(CGRect)rect colors:(NSArray*)someColors gradient:(BOOL)flag;


@end


@protocol FJSTableViewColorIndexDelegate <NSObject>

@optional
- (void)didTouchSegment:(int)segment inColorIndex:(FJSTableViewColorIndex*)index;

@end

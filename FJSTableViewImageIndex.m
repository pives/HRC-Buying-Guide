//
//  FJSTableViewColorIndex.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/4/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "FJSTableViewImageIndex.h"
#import "UIColor+extensions.h"
#import "UIView-Extensions.h"

@interface FJSTableViewImageIndex ()

- (int)segmentForPoint:(CGPoint)aPoint;

- (void)addOverlay;
- (void)removeOverlay;

@end




@implementation FJSTableViewImageIndex

//TODO: recalculate gradient if frame changes
//TODO: possible - flash grey outline when selected like alphabet index

@synthesize slider;
@synthesize numberOfSections;
@synthesize delegate;
@synthesize currentlyTouchedSegment;
@synthesize overlay;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {

    self.overlay = nil;
    self.slider = nil;
    [super dealloc];
}


- (id)initWithFrame:(CGRect)rect image:(UIImage*)anImage sections:(int)sections{
      
    self = [super initWithFrame:rectExpandedByValue(rect, 8)];

	if (self)
	{
        
        self.numberOfSections = sections;
        
        self.slider = [[UIImageView alloc] initWithImage:anImage];
        slider.frame = rectContractedByValue(self.bounds, 8);
        
        [self addSubview:slider];
        
    }
    return self;
}

#pragma mark -
#pragma mark UIResponder

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    

    [self addOverlay];
    CGPoint touchPoint = [[touches anyObject] locationInView:self];

    int newSegment = [self segmentForPoint:touchPoint];
    self.currentlyTouchedSegment = newSegment;
        
    if([delegate respondsToSelector:@selector(didTouchSegment:inColorIndex:)])
        [delegate didTouchSegment:self.currentlyTouchedSegment  inColorIndex:self];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    int newSegment = [self segmentForPoint:touchPoint];
    
    if(newSegment != currentlyTouchedSegment){
        
        self.currentlyTouchedSegment = newSegment;
        
        if([delegate respondsToSelector:@selector(didTouchSegment:inColorIndex:)])
            [delegate didTouchSegment:self.currentlyTouchedSegment  inColorIndex:self];

    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self removeOverlay];
    [super touchesEnded:touches withEvent:event];
    
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self removeOverlay];
    [super touchesCancelled:touches withEvent:event];
    
}


#pragma mark -
#pragma mark Find segment for touch 
- (int)segmentForPoint:(CGPoint)aPoint{
    
    float segmentLength = self.frame.size.height/self.numberOfSections;

    int segment = -1;
    
    CGRect segmentFrame;
    segmentFrame.size = CGSizeMake(self.frame.size.width, segmentLength);
    
    for(int i = 0; i<numberOfSections; i++){
        
        segmentFrame.origin = CGPointMake(0 , 0 + (i * segmentLength));
        
        if(CGRectContainsPoint(segmentFrame, aPoint)){
            segment  = i;
            break;
        }
    }
    
    return segment;
}


#pragma mark -
#pragma mark Overlay Layer

- (void)addOverlay{
    
    int overlayOutset = 5;
    
    CALayer* newlayer = [CALayer layer];
    newlayer.cornerRadius = (slider.frame.size.width/2) + overlayOutset;
    newlayer.backgroundColor = [UIColor grayColor].CGColor;
    newlayer.opacity = 0.5;
    
    newlayer.frame = rectExpandedByValue(slider.frame, overlayOutset);
    
    self.overlay = newlayer;
    [self.layer insertSublayer:overlay atIndex:0];
    
}

- (void)removeOverlay{
    
    [overlay removeFromSuperlayer];
    
}


@end


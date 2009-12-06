//
//  FJSTableViewColorIndex.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/4/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "FJSTableViewColorIndex.h"
#import "UIColor+extensions.h"

@interface FJSTableViewColorIndex ()

- (NSArray*)CGColorsFromUIColors:(NSArray*)someColors;
- (NSArray*)gradientColorsWithColor:(UIColor*)aColor;
- (CAGradientLayer*)diagonalGradientWithColors:(NSArray*)someColors frame:(CGRect)aFrame cornerRadius:(float)aRadius;
- (CALayer*)layerWithColor:(UIColor*)aColor frame:(CGRect)aFrame cornerRadius:(float)aRadius;

- (void)drawSegments;
- (void)drawSegmentsShiny;
- (void)drawSegemntDividers;

- (void)drawGradient;
- (int)segmentForPoint:(CGPoint)aPoint;

- (void)addOverlay;
- (void)removeOverlay;

@end




@implementation FJSTableViewColorIndex

//TODO: recalculate gradient if frame changes
//TODO: possible - flash grey outline when selected like alphabet index

@synthesize colors;
@synthesize delegate;
@synthesize currentlyTouchedSegment;
@synthesize overlay;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {

    self.overlay = nil;
    self.colors = nil;
    [super dealloc];
}


- (id)initWithFrame:(CGRect)rect colors:(NSArray*)someColors gradient:(BOOL)flag{
    
    self = [super initWithFrame:rect];
	if (self)
	{
        self.colors = someColors;
        self.layer.cornerRadius = 8;
        self.backgroundColor = [UIColor grayColor];
        
        CALayer* gutter = [CALayer layer];
        gutter.cornerRadius = self.layer.cornerRadius-1;
        gutter.backgroundColor = [UIColor blackColor].CGColor;
        gutter.frame = CGRectMake(1, 1, self.layer.frame.size.width-2, self.layer.frame.size.height-2);
        [self.layer addSublayer:gutter];
        
        
        if(flag)
            [self drawGradient];
        else 
            [self drawSegments];
        //[self drawSegmentsShiny];
    
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
    
    float innerSegmentStart = 2;
    //float innerSegmentEnd = self.layer.frame.size.height - 2;
    float innerSegmentWidthStart = 2;
    //float innerSegmentWidthEnd = self.layer.frame.size.width-2;
    
    float totalInnerSegmentHeight = (self.layer.frame.size.height - 4);
    
    float segmentLength = totalInnerSegmentHeight/[self.colors count];
    //float segmentWidth = self.layer.frame.size.width - 4;
    
    //float segmentCornerRadius = self.layer.cornerRadius - 2;
    
    
    int segment = -1;
    
    CGRect segmentFrame;
    segmentFrame.size = CGSizeMake(self.layer.frame.size.width, segmentLength);
    
    for(int i = 0; i<[colors count]; i++){
        
        segmentFrame.origin = CGPointMake(innerSegmentWidthStart , innerSegmentStart + (i*segmentLength));
        
        if(CGRectContainsPoint(segmentFrame, aPoint)){
            segment  = i;
            break;
        }
    }
    
    return segment;
}



#pragma mark -
#pragma mark draw segments

- (void)drawSegmentsShiny{
    
    //A lot of numbers I will need
    
    float innerSegmentStart = 2;
    //float innerSegmentEnd = self.layer.frame.size.height - 2;
    float innerSegmentWidthStart = 2;
    //float innerSegmentWidthEnd = self.layer.frame.size.width-2;
    
    float totalInnerSegmentHeight = (self.layer.frame.size.height - 4);
    
    float segmentLength = totalInnerSegmentHeight/[self.colors count];
    float segmentWidth = self.layer.frame.size.width - 4;
    
    float segmentCornerRadius = self.layer.cornerRadius - 2;
    
    NSArray* topColors = [self gradientColorsWithColor:[colors objectAtIndex:0]];
    
    
    CGRect topFrame = CGRectMake(innerSegmentWidthStart, 
                                 innerSegmentStart, 
                                 segmentWidth, 
                                 (segmentLength + segmentCornerRadius));
    
    
    CAGradientLayer* top = [self diagonalGradientWithColors:topColors 
                                                      frame:topFrame 
                                               cornerRadius:segmentCornerRadius];
        
    [self.layer addSublayer:top];
    
    
    CGRect bottomFrame = CGRectMake(innerSegmentWidthStart, 
                                    (innerSegmentStart + (([colors count]-1)*segmentLength)) - segmentCornerRadius, 
                                    segmentWidth, 
                                    (segmentLength + segmentCornerRadius));
    
    
    NSArray* bottomColors = [self gradientColorsWithColor:[colors lastObject]];
    
    CAGradientLayer* bottom = [self diagonalGradientWithColors:bottomColors 
                                                         frame:bottomFrame 
                                                  cornerRadius:segmentCornerRadius];
    
    
    [self.layer addSublayer:bottom];
    
    
    int i = 0;
    for(UIColor* eachColor in self.colors){
        
        if( !(eachColor == [self.colors objectAtIndex:0]) && 
           !(eachColor == [self.colors lastObject]) ){
            
            
            CGRect middleFrame = CGRectMake(innerSegmentWidthStart, 
                                            (innerSegmentStart + (i*segmentLength)), 
                                            segmentWidth, 
                                            segmentLength);
            
            
            NSArray* middleColors = [self gradientColorsWithColor:eachColor];
            
            CAGradientLayer* middle = [self diagonalGradientWithColors:middleColors 
                                                                 frame:middleFrame 
                                                          cornerRadius:0];
            
            
            
            [self.layer addSublayer:middle];
            
            
        }
                       
        i++;
        
    }
    /*
    CGRect middleFrame = CGRectMake(innerSegmentWidthStart, 
                                    (innerSegmentStart + (1*segmentLength)), 
                                    segmentWidth, 
                                    segmentLength);
    
    NSArray* middleColors = [self gradientColorsWithColor:[colors objectAtIndex:1]];
    
    CAGradientLayer* middle = [self diagonalGradientWithColors:middleColors 
                                                         frame:middleFrame 
                                                  cornerRadius:0];
        
    [self.layer addSublayer:middle];
    */
    [self drawSegemntDividers];
    
}


- (void)drawSegments{
    
    //A lot of numbers I will need
    
    float innerSegmentStart = 2;
    //float innerSegmentEnd = self.layer.frame.size.height - 2;
    float innerSegmentWidthStart = 2;
    //float innerSegmentWidthEnd = self.layer.frame.size.width-2;
    
    float totalInnerSegmentHeight = (self.layer.frame.size.height - 4);
    
    float segmentLength = totalInnerSegmentHeight/[self.colors count];
    float segmentWidth = self.layer.frame.size.width - 4;
    
    float segmentCornerRadius = self.layer.cornerRadius - 2;
    
    CGRect topFrame = CGRectMake(innerSegmentWidthStart, 
                                 innerSegmentStart, 
                                 segmentWidth, 
                                 (segmentLength + segmentCornerRadius));
    
    
    CALayer* top = [self layerWithColor:[colors objectAtIndex:0] frame:topFrame cornerRadius:segmentCornerRadius];
    
    [self.layer addSublayer:top];
    
    
    CGRect bottomFrame = CGRectMake(innerSegmentWidthStart, 
                                    (innerSegmentStart + (([colors count]-1)*segmentLength)) - segmentCornerRadius, 
                                    segmentWidth, 
                                    (segmentLength + segmentCornerRadius));
    
    
    CALayer* bottom = [self layerWithColor:[colors lastObject] frame:bottomFrame cornerRadius:segmentCornerRadius];
    
    [self.layer addSublayer:bottom];
    
    
    int i = 0;
    for(UIColor* eachColor in self.colors){
        
        if( !(eachColor == [self.colors objectAtIndex:0]) && 
           !(eachColor == [self.colors lastObject]) ){
            
            
            CGRect middleFrame = CGRectMake(innerSegmentWidthStart, 
                                            (innerSegmentStart + (i*segmentLength)), 
                                            segmentWidth, 
                                            segmentLength);
            
            CALayer* middle = [self layerWithColor:eachColor frame:middleFrame cornerRadius:0];
            
            
            [self.layer addSublayer:middle];
            
            
        }
        
        i++;
        
    }
    
    [self drawSegemntDividers];
    
}

- (void)drawSegemntDividers{
    
    //A lot of numbers I will need

    
    float innerSegmentStart = 2;
    //float innerSegmentEnd = self.layer.frame.size.height - 2;
    float innerSegmentWidthStart = 2;
    //float innerSegmentWidthEnd = self.layer.frame.size.width-2;
    
    float totalInnerSegmentHeight = (self.layer.frame.size.height - 4);
    
    float segmentLength = totalInnerSegmentHeight/[self.colors count];
    float segmentWidth = self.layer.frame.size.width - 4;
    
    //float segmentCornerRadius = self.layer.cornerRadius - 2;
    
    CGSize size = CGSizeMake(segmentWidth, 1);
    
    UIColor* dividerColor = [UIColor blackColor];
    
    CALayer* divider;
    
    for(int i = 1; i<[colors count]; i++){
        
        divider = [CALayer layer];
        divider.backgroundColor = dividerColor.CGColor;
        divider.frame = CGRectMake(innerSegmentWidthStart,
                                   innerSegmentStart + (i*segmentLength),
                                   size.width,
                                   size.height);
        
        [self.layer addSublayer:divider];
                
    }
            
}

- (void)drawGradient{
    
    float innerSegmentStart = 2;
    //float innerSegmentEnd = self.layer.frame.size.height - 2;
    float innerSegmentWidthStart = 2;
    //float innerSegmentWidthEnd = self.layer.frame.size.width-2;
    
    float totalInnerSegmentHeight = (self.layer.frame.size.height - 4);
    
    //float segmentLength = totalInnerSegmentHeight/[self.colors count];
    float segmentWidth = self.layer.frame.size.width - 4;
    
    float segmentCornerRadius = self.layer.cornerRadius - 2;
    
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(innerSegmentWidthStart, 
                                     innerSegmentStart, 
                                     segmentWidth, 
                                     totalInnerSegmentHeight);
    
    gradientLayer.cornerRadius = segmentCornerRadius;
    gradientLayer.colors = [self CGColorsFromUIColors:self.colors];
    [self.layer addSublayer:gradientLayer];
    
    
    
}


#pragma mark -
#pragma mark CALayers

- (CAGradientLayer*)diagonalGradientWithColors:(NSArray*)someColors frame:(CGRect)aFrame cornerRadius:(float)aRadius{
    
    CAGradientLayer* newLayer = [CAGradientLayer layer];
    newLayer.frame = aFrame;
    newLayer.cornerRadius = aRadius;
    newLayer.startPoint = CGPointMake(0, 0);
    newLayer.endPoint = CGPointMake(1, 1);
    newLayer.colors = [self CGColorsFromUIColors:someColors];
    
    return newLayer;
    
}

- (CALayer*)layerWithColor:(UIColor*)aColor frame:(CGRect)aFrame cornerRadius:(float)aRadius{
    
    CALayer* newLayer = [CALayer layer];
    newLayer.frame = aFrame;
    newLayer.cornerRadius = aRadius;
    newLayer.backgroundColor = aColor.CGColor;    
    return newLayer;
    
}


#pragma mark -
#pragma mark Overlay Layer

- (void)addOverlay{
    
    CALayer* newlayer = [CALayer layer];
    newlayer.cornerRadius = self.layer.cornerRadius+4;
    newlayer.backgroundColor = [UIColor grayColor].CGColor;
    newlayer.opacity = 0.5;
    newlayer.frame = CGRectMake(-4, -4, self.layer.frame.size.width+8, self.layer.frame.size.height+8);
    
    self.overlay = newlayer;
    [self.layer insertSublayer:overlay atIndex:0];
    
}

- (void)removeOverlay{
    
    [overlay removeFromSuperlayer];
    
}




#pragma mark -
#pragma mark Colors


- (NSArray*)gradientColorsWithColor:(UIColor*)aColor{
    
    
    UIColor* light = [aColor colorByAdding:0.1];
    UIColor* dark = [aColor colorByDarkeningTo:0.6];

    return [NSArray arrayWithObjects:light, aColor, dark, nil];
    
}

- (NSArray*)CGColorsFromUIColors:(NSArray*)someColors{
    
    NSMutableArray* CGColors = [NSMutableArray array];
    for(UIColor* eachColor in someColors){
        
        [CGColors addObject:(id)eachColor.CGColor];
        
    }
    
    return CGColors;
}




@end


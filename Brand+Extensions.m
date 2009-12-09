//
//  Brand+Extensions.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/8/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "Brand+Extensions.h"


@implementation Brand(Extensions)

- (NSString*)ratingFormatted{
    
    NSString* r;
    
    if([self.rating intValue] == -1){
        
        r = @"?";
    }else {
        r = [self.rating description];
    }
	
    
    return r;
    
}

@end


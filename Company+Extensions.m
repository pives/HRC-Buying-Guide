//
//  Company+Extensions.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "Company+Extensions.h"


@implementation Company(Extensions)

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

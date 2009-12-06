//
//  Category+Extensions.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/24/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "Category+Extensions.h"
#import "NSString+extensions.h"


@implementation Category (Extensions)

- (NSString*)nameDisplayFriendly{
    

    NSString* displayName;
    
    if([self.name doesContainString:@"Road"]){
        
        displayName = @"Automotive";
        
    }else if([self.name doesContainString:@"Trip"]){
        
        displayName = @"Travel and Leisure";
        
    }else if([self.name doesContainString:@"Filling"]){
        
        displayName = @"Oil & Gas";
        
    }else if([self.name doesContainString:@"Shop"]){
        
        displayName = @"Retailers";

    }else if([self.name doesContainString:@"Insurance"]){
        
        displayName = @"Insurance";
        
    }else if([self.name doesContainString:@"Entertained"]){
        
        displayName = @"Entertainment";

    }else if([self.name doesContainString:@"Eating"]){
        
        displayName = @"Restaurants";

    }else if([self.name doesContainString:@"Mail"]){
        
        displayName = @"Shipping";

    }else if([self.name doesContainString:@"Newsstand"]){
        
        displayName = @"Newsstand";
        
    }else{
        
        displayName = self.name;

    }        
    
    return displayName;
}

@end

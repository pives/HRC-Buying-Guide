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
    
    if([self.name doesContainString:@"Apparel"]){
        
        displayName = @"Apparel";
        
    }else if([self.name doesContainString:@"Finance"]){
        
        displayName = @"Finance";
        
    }else if([self.name doesContainString:@"Filling"]){
        
        displayName = @"Oil & Gas";
        
    }else if([self.name doesContainString:@"Food"]){

        displayName = @"Food & Bev";

    }else if([self.name doesContainString:@"Household"]){
        
        displayName = @"Household";

    }else if([self.name doesContainString:@"Insurance"]){
        
        displayName = @"Insurance";
        
    }else if([self.name doesContainString:@"Entertained"]){
        
        displayName = @"Entertainment";

    }else if([self.name doesContainString:@"Eating"]){
        
        displayName = @"Restaurants";

    }else if([self.name doesContainString:@"Mail"]){
        
        displayName = @"Shipping";

    }else{
        
        displayName = self.name;

    }        
    
    return displayName;
}

@end

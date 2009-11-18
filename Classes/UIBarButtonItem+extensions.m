//
//  UIBarButtonItem+extensions.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "UIBarButtonItem+extensions.h"


@implementation UIBarButtonItem(extensions)

+ (UIBarButtonItem*)flexibleSpaceItem{
    
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:nil] autorelease];
    
    
}

+ (UIBarButtonItem*)itemWithView:(UIView*)aView{
    
    return [[[UIBarButtonItem alloc] initWithCustomView:aView] autorelease];
    
}

+ (UIBarButtonItem*)itemWithTitle:(NSString*)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    
    return [[[UIBarButtonItem alloc] initWithTitle:title style:style target:target action:action] autorelease];

}

+ (UIBarButtonItem*)systemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action{
    
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:target action:action] autorelease];
    
}

+ (NSArray*)centeredToolButtonsItems:(NSArray*)toolBarItems{
    
    NSMutableArray* items = [NSMutableArray array];
    [items addObject:[UIBarButtonItem flexibleSpaceItem]];
    [items addObjectsFromArray:toolBarItems];
    [items addObject:[UIBarButtonItem flexibleSpaceItem]];
    
    return items;
}

@end

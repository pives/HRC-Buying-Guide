//
//  UIBarButtonItem+extensions.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIBarButtonItem(extensions)

+ (UIBarButtonItem*)flexibleSpaceItem;
+ (UIBarButtonItem*)itemWithView:(UIView*)aView;
+ (UIBarButtonItem*)itemWithTitle:(NSString*)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)systemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;
+ (NSArray*)centeredToolButtonsItems:(NSArray*)toolBarItems;

@end

//
//  ColoredTableViewCell.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/19/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColoredTableViewCell : UITableViewCell {
    
    UIColor* cellColor;

}
@property(nonatomic,retain)UIColor *cellColor;


@end

//
//  ColoredTableViewCell.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/19/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "ColoredTableViewCell.h"
#import "UIView-Extensions.h"


@implementation ColoredTableViewCell

@synthesize cellColor;


- (void) dealloc
{
    self.cellColor = nil;
    [super dealloc];
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self setBackgroundColor:cellColor recursive:YES];
    
    /*
    self.textLabel.backgroundColor = cellColor;
    self.detailTextLabel.backgroundColor = cellColor;
    self.contentView.backgroundColor = cellColor;
    self.accessoryView.backgroundColor = cellColor;
     */
}




@end

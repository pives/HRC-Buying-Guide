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
    
    /*
    if(!selected){
        [self.backgroundView setBackgroundColor:cellColor];
        self.textLabel.backgroundColor = cellColor;
        self.contentView.backgroundColor = cellColor;
        self.detailTextLabel.backgroundColor = cellColor;
    }
    */ 
    
    //MARK
    /*
    if(!selected)
        [self setBackgroundColor:cellColor recursive:YES];
    */
    /*
    UIView* background = [[UIView alloc] initWithFrame:self.frame];
    background.backgroundColor = cellColor;
    self.backgroundView = background;
    [background release];
    
    UILabel* company = (UILabel*)[self viewWithTag:1000];
    UILabel* rating = (UILabel*)[self viewWithTag:999];

    rating.backgroundColor = cellColor;
    company.backgroundColor = cellColor;
    */
    
    
    /*
    self.textLabel.backgroundColor = cellColor;
    self.detailTextLabel.backgroundColor = cellColor;
    self.contentView.backgroundColor = cellColor;
    self.accessoryView.backgroundColor = cellColor;
     */
}




@end

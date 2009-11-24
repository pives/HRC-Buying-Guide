//
//  KeyViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/20/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KeyViewController : UIViewController {
    
    UIScrollView* info;

}
@property(nonatomic,assign)IBOutlet UIScrollView *info;

- (IBAction)dismiss;

@end

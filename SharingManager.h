//
//  SharingManager.h
//  BuyingGuide
//
//  Created by Jake O'Brien on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "FacebookAgent.h"

@class BGCompany;

@interface SharingManager : NSObject <FacebookAgentDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate>


@property(nonatomic,retain)FacebookAgent *agent;
@property(nonatomic,assign)UIViewController *viewController;
@property(nonatomic,assign)BGCompany *company;

+ (SharingManager *)sharedSharingManager;
- (void)showSharingOptions;

@end

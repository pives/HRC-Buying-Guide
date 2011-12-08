//
//  SharingManager.m
//  BuyingGuide
//
//  Created by Jake O'Brien on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SharingManager.h"
#import "FJSTweetViewController.h"
#import "FJSTweetViewController+HRC.h"
#import "BGCompany.h"

static SharingManager *sharedSharingManager = nil;


@implementation SharingManager

@synthesize agent,viewController,company;

+ (SharingManager *)sharedSharingManager {
    @synchronized(self) {
        if (sharedSharingManager == nil)
            sharedSharingManager = [[SharingManager alloc] init];
        return sharedSharingManager;
    }
}

- (void)dealloc {
    self.agent = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark MFMailComposeViewController

- (void)sendEmail{
    
    if([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Support LGBT Equality When You Shop"]; //TODO: add subject
        
        NSString* fileName;
        NSString* fileExtension = @"txt";
        NSString* emailText;
        
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		NSString* rawLink = [info objectForKey:@"AppStoreURL"];
		//NSString* appStoreID = [info objectForKey:@"AppStoreIDCompounds"];
		NSString* appStoreID = [info objectForKey:@"AppStoreID"];
		/*
         NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
         NSString* urlPrefix = [info objectForKey:@"ScoreCardURLPrefix"];
         NSString* urlSuffix = [info objectForKey:@"ScoreCardURLSuffix"];
         NSString* companyID = [self.company.ID stringValue];
         NSString* companyScoreurl = [NSString stringWithFormat:@"%@%@%@", urlPrefix, companyID, urlSuffix];
         */
		
        
        if([self.company.nonResponder boolValue] == YES){
            
            fileName = @"EmailConfused";
            NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
            NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            emailText = [NSString stringWithFormat:fileContenets, 
                         company.name,
                         [company.rating stringValue],
                         nil
                         ];
            
            
        }else{
            
            if([self.company.ratingLevel intValue] == 0){
                
                //GOOD
                fileName = @"EmailHappy";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
                             self.company.name, 
                             [self.company.rating stringValue],
                             nil
                             ];
                
                
            }else if([self.company.ratingLevel intValue] == 1){
                
                //MIDDLE
                fileName = @"EmailIndifferent";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
                             self.company.name, 
                             [self.company.rating stringValue],
                             nil
                             ];
                
                
            }else{
                
                fileName = @"EmailSad";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
                NSString *fileContenets = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                emailText = [NSString stringWithFormat:fileContenets, 
                             self.company.name, 
                             [self.company.rating stringValue],
                             nil
                             ];
                
            }
            
            
        }
		
		
        
        [controller setMessageBody:emailText isHTML:YES];
        [self.viewController presentModalViewController:controller animated:YES];
        [controller release];
        
    }else{
        
        UIAlertView* message = [[[UIAlertView alloc] initWithTitle:@"Cannot send email"
                                                           message:@"Email is currently unavailable. Please check your email settings and try again." 
                                                          delegate:self 
                                                 cancelButtonTitle:@"OK" 
                                                 otherButtonTitles:nil] autorelease];
        [message show];
        
        
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	//TODO: Check result?
    [self.viewController becomeFirstResponder];
	[self.viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark FJSTweetViewController

- (void)postTweet{
	
	FJSTweetViewController* tvc = [[FJSTweetViewController alloc] initWithCompany:self.company];
	
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:tvc];
	nc.navigationBarHidden = YES;
	
	[self.viewController presentModalViewController:nc animated:YES];
	
	[tvc release];
	[nc release];
}


#pragma mark -
#pragma mark Facebook

///////////////////////////////////////////////////////////////////////////////////////////////////
// This application will not work until you enter your Facebook application's API key here:

static NSString* kApiKey = @"a103b98ed528fc842fd1daa9c7c97713";

// Enter either your API secret or a callback URL (as described in documentation):
static NSString* kApiSecret = @"514d14ac9dd9ef105d5207ca62accd3e"; // @"<YOUR SECRET KEY>";


- (void)sendFacebookPost{
    
    if(self.agent == nil){
        
        self.agent = [[[FacebookAgent alloc] initWithApiKey:kApiKey ApiSecret:kApiSecret ApiProxy:nil] autorelease];
        agent.delegate = self;
    }
    
    
    NSString* someText;
	
    if([self.company.nonResponder boolValue] == YES){
        
        someText = 
        @"HRC’s Buying For Workplace Equality Guide gives %@ an unofficial score of %i%%. They have failed to respond to our survey despite repeated attempts.  For more information and to download the iPhone app visit http://bit.ly/buy4eq";
        
    }else{
        
        if([self.company.ratingLevel intValue] == 0){
            
            someText = 
            @"HRC’s Buying For Workplace Equality Guide rates %@ %i%%. They receive one of the highest workplace equality scores. For more information and to download the iPhone app visit http://bit.ly/buy4eq";
            
            
        }else if([self.company.ratingLevel intValue] == 1){
            
            someText = 
            @"HRC’s Buying For Workplace Equality Guide rates %@ %i%%. They receive a moderate workplace equality score.  For more information and to download the iPhone app visit http://bit.ly/buy4eq";
            
            
        }else{
            
            someText = 
            @"HRC’s Buying For Workplace Equality Guide rates %@ %i%%. They receive one of the lowest workplace equality scores.  For more information and to download the iPhone app visit http://bit.ly/buy4eq";
            
        }
        
    }
    
    
	someText = [NSString stringWithFormat:someText, self.company.name, [self.company.rating intValue]];
    
    
    [agent publishFeedWithName:@"HRC Buying for Workplace Equality iPhone App" //can put it here
				   captionText:someText 
					  imageurl:@"http://www.hrc.org/buyersguide2010/images/2011-iphone_icon-90x90.png" 
					   linkurl:@"http://www.hrc.org/iPhone" 
			 userMessagePrompt:[NSString stringWithFormat:@"Tell others about %@",self.company.name]];
    
}

- (void) facebookAgent:(FacebookAgent*)agent didLoadInfo:(NSDictionary*) info{
    
    DebugLog(@"request load info: %@", [info description]);
    
}

- (void) facebookAgent:(FacebookAgent*)agent requestFaild:(NSString*) message{
    
	NSLog(@"Facebook request failed: %@", message);
}


- (void) facebookAgent:(FacebookAgent*)agent loginStatus:(BOOL) loggedIn{
	
	if(loggedIn)
		DebugLog(@"loggedin");
	
	DebugLog(@"should be logged in");
	
}

- (void) facebookAgent:(FacebookAgent*)agent statusChanged:(BOOL) success{
	
	if(success){
        DebugLog(@"YES!");
    }
	else {
		DebugLog(@"NO!");
	}
}


- (void) facebookAgent:(FacebookAgent*)agent dialog:(FBDialog*)dialog didFailWithError:(NSError*)error{
	
	NSLog(@"Facebook dialog failed with error: %@", [error description]);
	
}


#pragma mark -
#pragma mark UIActionSheet

- (void)showSharingOptions{
    
    UIActionSheet* myActionSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Help spread the word about %@", self.company.name] 
                                                                delegate:self 
                                                       cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"Twitter", @"Facebook", @"Email", nil] autorelease];
    
    
    myActionSheet.actionSheetStyle=UIActionSheetStyleAutomatic;
    [myActionSheet showInView:self.viewController.view];
    
}




#pragma mark -
#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)modalViewSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    switch (buttonIndex)
    {
		case 0:
        {
            [self postTweet];
            break;
        }
		case 1:
        {
            [self sendFacebookPost];
            break;
        }
        case 2:
        {
            [self sendEmail];
            break;
        }
    }
}


@end

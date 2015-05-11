//
//  HamQTHLookupResultTableViewController.h
//  HamQTH Lookup
//
//  Created by Fabrice Masachs on 5/10/15.
//  Copyright (c) 2015 Fabrice Masachs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "HamQTH.h"

@interface HamQTHLookupResultTableViewController : UITableViewController <NSXMLParserDelegate, MFMailComposeViewControllerDelegate>

@property (retain, nonatomic) NSString *callsign;
@property (strong, nonatomic) NSMutableArray *lookupOutputArray;
@property (strong, nonatomic) NSMutableString *nodeContent;
@property (strong, nonatomic) NSXMLParser *xmlParser;
@property (strong, nonatomic) HamQTH *hamQTH;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *sessionError;

@end
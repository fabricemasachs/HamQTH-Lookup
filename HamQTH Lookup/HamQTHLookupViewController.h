//
//  HamQTHLookupViewController.h
//  HamQTH Lookup
//
//  Created by Fabrice Masachs on 5/10/15.
//  Copyright (c) 2015 Fabrice Masachs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HamQTHLookupViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSString *callsignToSearch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginInformationButton;
@property (strong, nonatomic) IBOutlet UITextField *callsignToSearchTextField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

- (IBAction)loginInformationButtonAction:(id)sender;
- (IBAction)searchButtonAction:(id)sender;

@end

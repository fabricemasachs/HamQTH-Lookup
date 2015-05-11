//
//  HamQTHLoginSettingViewController.h
//  HamQTH Lookup
//
//  Created by Fabrice Masachs on 5/10/15.
//  Copyright (c) 2015 Fabrice Masachs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HamQTHLoginSettingViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UILabel *joinHamQTHLabel;

- (IBAction)cancelButtonItemAction:(id)sender;
- (IBAction)saveButtonItemAction:(id)sender;

@end
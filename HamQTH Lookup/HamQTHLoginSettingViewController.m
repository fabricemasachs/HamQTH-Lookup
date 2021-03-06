//
//  HamQTHLoginSettingViewController.m
//  HamQTH Lookup
//
//  Created by Fabrice Masachs on 5/10/15.
//  Copyright (c) 2015 Fabrice Masachs. All rights reserved.
//

#import "HamQTHLoginSettingViewController.h"

@interface HamQTHLoginSettingViewController ()

@end

@implementation HamQTHLoginSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    
    self.usernameTextField.text = [userSettings stringForKey:@"hamQthUsernameKey"];
    self.passwordTextField.text = [userSettings stringForKey:@"hamQthPasswordKey"];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.joinHamQTHLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *joinHamQth = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(joinHamQthAction:)];
    [self.joinHamQTHLabel addGestureRecognizer:joinHamQth];
    joinHamQth.numberOfTapsRequired = 1;
    joinHamQth.cancelsTouchesInView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    
    if ([self.usernameTextField.text isEqualToString:@""]) {
        [userSettings removeObjectForKey:@"hamQthUsernameKey"];
        [userSettings synchronize];
    } else {
        [userSettings setObject:self.usernameTextField.text forKey:@"hamQthUsernameKey"];
        [userSettings synchronize];
    }
    
    if ([self.passwordTextField.text isEqualToString:@""]) {
        [userSettings removeObjectForKey:@"hamQthPasswordKey"];
        [userSettings synchronize];
    } else {
        [userSettings setObject:self.passwordTextField.text forKey:@"hamQthPasswordKey"];
        [userSettings synchronize];
    }
    
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)hideKeyboard {
    [self.usernameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
}

- (IBAction)cancelButtonItemAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonItemAction:(id)sender {
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    
    [userSettings setObject:self.usernameTextField.text forKey:@"hamQthUsernameKey"];
    [userSettings setObject:self.passwordTextField.text forKey:@"hamQthPasswordKey"];
    
    [userSettings synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)joinHamQthAction:(UITapGestureRecognizer *)joinHamQth {
    NSString *launchUrl = @"http://www.hamqth.com/register.php";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
}

@end
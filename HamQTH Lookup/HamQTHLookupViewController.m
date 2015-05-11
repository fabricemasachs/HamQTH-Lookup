//
//  HamQTHLookupViewController.m
//  HamQTH Lookup
//
//  Created by Fabrice Masachs on 5/10/15.
//  Copyright (c) 2015 Fabrice Masachs. All rights reserved.
//

#import "HamQTHLookupViewController.h"
#import "HamQTHLookupResultTableViewController.h"
#import "HamQTHLoginSettingViewController.h"
#import "Macros.h"

@interface HamQTHLookupViewController ()

@end

@implementation HamQTHLookupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.callsignToSearchTextField.delegate = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginInformationButtonAction:(id)sender {
    HamQTHLoginSettingViewController *viewController = [[HamQTHLoginSettingViewController alloc]init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)searchButtonAction:(id)sender {
    self.callsignToSearch = self.callsignToSearchTextField.text;
    
    if (self.callsignToSearchTextField.text.length >= 3) {
        [self.callsignToSearchTextField endEditing:YES];
        [self performSegueWithIdentifier:@"showHamQTHLookupResultTableViewController" sender:self];
    } else {
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchButtonAction:self];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.callsignToSearchTextField resignFirstResponder];
    
}

- (void)hideKeyboard {
    [self.callsignToSearchTextField endEditing:YES];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showHamQTHLookupResultTableViewController"]) {
        HamQTHLookupResultTableViewController *viewController = (HamQTHLookupResultTableViewController *)segue.destinationViewController;
        viewController.callsign = self.callsignToSearch;
    }
}

@end

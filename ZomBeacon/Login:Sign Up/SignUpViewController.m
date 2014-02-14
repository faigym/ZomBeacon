//
//  SignUpViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)fieldsAreValid
{
    if (self.usernameField.text.length > 0 && self.passwordField.text.length > 0 && self.emailField.text.length > 0 && self.nameField.text > 0)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

//User sign up method using the Parse framework
- (IBAction)signUpNewUser
{
    if ([self fieldsAreValid]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            PFUser *user = [PFUser user];
            user.username = self.usernameField.text;
            user.password = self.passwordField.text;
            user.email = self.emailField.text;
            user[@"name"] = self.nameField.text;
            user[@"bio"] = self.bioField.text;
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (!error)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Successful!" message:@"You will receive an email to confirm your account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     
                     [alert show];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     });
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 else
                 {
                     NSLog(@"Error signing user up.");
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     });
                 }
             }];
        });
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account creation is not complete." message:@"You cannot leave any of the following fields blank: username, password, email, or name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
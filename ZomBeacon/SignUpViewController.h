//
//  SignUpViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SignUpViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *bioField;

-(IBAction)signUpNewUser;

@end
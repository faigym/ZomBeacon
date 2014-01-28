//
//  JoinViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "JoinedViewController.h"

@interface JoinViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *joinGameField;

- (IBAction)joinGame;

@end
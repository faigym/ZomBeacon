//
//  JoinedViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinedViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *hostUserLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@property (nonatomic, weak) NSString *hostUserLabelString;
@property (nonatomic, weak) NSString *dateTimeLabelString;
@property (nonatomic, weak) NSString *locationLabelString;


@end
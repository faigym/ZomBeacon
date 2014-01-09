//
//  MainViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}

//Method that logs the user out with the Parse framework
- (IBAction)logUserOut
{
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

//Method that selects a random team for the user
- (IBAction)selectRandomTeam
{
    int randomNumber = [self getRandomNumberBetween:1 to:100];
    
    UIStoryboard *storyboard;
    if(IS_IPAD)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    else
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    
    if (randomNumber > 0 && randomNumber < 75 )
    {
        InfectedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"infected"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        SurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"survivor"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

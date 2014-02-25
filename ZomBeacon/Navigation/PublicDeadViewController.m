//
//  PublicDeadViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/24/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PublicDeadViewController.h"

@interface PublicDeadViewController ()

@end

@implementation PublicDeadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	currentUser = [PFUser currentUser];
}

//Lets you rejoin the game for 5,000 points docked off your overall score
- (IBAction)rejoinGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    int randomNumber = [self getRandomNumberBetween:1 to:100];
    
    if (randomNumber < 20)
    {
        PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
        [self.navigationController pushViewController:vc animated:YES];
        [currentUser setObject:@"zombie" forKey:@"publicStatus"];
        [currentUser setObject:@"YES" forKey:@"joinedPublic"];
        [currentUser saveInBackground];
    }
    else
    {
        PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
        [self.navigationController pushViewController:vc animated:YES];
        [currentUser setObject:@"survivor" forKey:@"publicStatus"];
        [currentUser setObject:@"YES" forKey:@"joinedPublic"];
        [currentUser saveInBackground];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject *theUserScore = [query getFirstObject];
    float score = [theUserScore[@"publicScore"] floatValue];
    float points = 5000.0f;
    NSNumber *sum = [NSNumber numberWithFloat:score - points];
    [theUserScore setObject:sum forKey:@"publicScore"];
    [theUserScore saveInBackground];
}

//Sends you back to the main menu
- (IBAction)goHome
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
    vc.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

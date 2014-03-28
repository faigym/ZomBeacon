//
//  MainMenuViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    if (IS_IPHONE4S)
    {
        CGRect frame = self.startPublicGameButton.frame;
        frame.size.width = 224;
        frame.size.height = 222;
        self.startPublicGameButton.frame = frame;
        self.startPublicGameButton.center = CGPointMake(121, 135);
        
        CGRect frame2 = self.createPrivateGameButton.frame;
        frame2.size.width = 154;
        frame2.size.height = 154;
        self.createPrivateGameButton.frame = frame2;
        self.createPrivateGameButton.center = CGPointMake(232, 289);
        
        CGRect frame3 = self.findPrivateGameButton.frame;
        frame3.size.width = 107;
        frame3.size.height = 107;
        self.findPrivateGameButton.frame = frame3;
        self.findPrivateGameButton.center = CGPointMake(128, 352);
    }
    
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;

    currentUser = [PFUser currentUser];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"TitilliumWeb-SemiBold" size:22], NSFontAttributeName, [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1], NSForegroundColorAttributeName, nil]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:currentUser forKey:@"owner"];
    [currentInstallation saveInBackground];
}

- (void)viewDidAppear:(BOOL)animated
{
    //Refreshes currentUser data
    [currentUser refresh];
}

- (IBAction)startPublicGame
{
    if ([currentUser[@"publicStatus"] isEqualToString:@"zombie"])
    {
        [self performSegueWithIdentifier: @"publicZombie" sender: self];
    }
    else if ([currentUser[@"publicStatus"] isEqualToString:@"survivor"])
    {
        [self performSegueWithIdentifier: @"publicSurvivor" sender: self];
    }
    else if ([currentUser[@"publicStatus"] isEqualToString:@"dead"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YOU ARE DEAD" message:@"Do you want to rejoin this game for -2,000 points?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    else
    {
        int randomNumber = [self getRandomNumberBetween:1 to:100];
        
        if (randomNumber < 20)
        {
            [self performSegueWithIdentifier: @"publicZombie" sender: self];
            [currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
        else
        {
            [self performSegueWithIdentifier: @"publicSurvivor" sender: self];
            [currentUser setObject:@"survivor" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        int randomNumber = [self getRandomNumberBetween:1 to:100];
        
        if (randomNumber < 20)
        {
            [self performSegueWithIdentifier: @"publicZombie" sender: self];
            [currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
        else
        {
            [self performSegueWithIdentifier: @"publicSurvivor" sender: self];
            [currentUser setObject:@"survivor" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        PFObject *theUserScore = [query getFirstObject];
        float score = [theUserScore[@"publicScore"] floatValue];
        float points = 2000.0f;
        NSNumber *sum = [NSNumber numberWithFloat:score - points];
        [theUserScore setObject:sum forKey:@"publicScore"];
        [theUserScore saveInBackground];
    }
    else
    {
        //Do nothing
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
    // Dispose of any resources that can be recreated.
}

@end

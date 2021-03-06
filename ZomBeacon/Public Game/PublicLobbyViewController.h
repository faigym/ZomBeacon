//
//  PublicLobbyViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendProfileViewController.h"
#import "UserLobbyCell.h"
#import "MBProgressHUD.h"
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import "PublicZombieViewController.h"
#import "PublicSurvivorViewController.h"

@interface PublicLobbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *thePlayers;
@property (nonatomic, strong) NSMutableArray *theScores;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;
@property (nonatomic, weak) IBOutlet UILabel *totalZombiesGlobally;
@property (nonatomic, weak) IBOutlet UILabel *totalSurvivorsGlobally;

- (NSArray *)getPlayersInCurrentGame;

@end

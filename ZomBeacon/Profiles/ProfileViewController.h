//
//  ProfileViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/17/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "GameDetailsViewController.h"
#import "GameCell.h"
#import <GameKit/GameKit.h>

@interface ProfileViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, GKGameCenterControllerDelegate, UIActionSheetDelegate>
{
    NSMutableArray *allImages;
    PFUser *currentUser;
    PFObject *privateGame;
}

@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UILabel *realName;
@property (nonatomic, weak) IBOutlet UILabel *emailAddress;
@property (nonatomic, weak) IBOutlet UILabel *shortBio;
@property (nonatomic, weak) IBOutlet UILabel *userScore;
@property (nonatomic, weak) IBOutlet PFImageView *profileImage;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *gamesArray;
@property (nonatomic, strong) NSMutableArray *privateGames;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;

- (NSMutableArray *)getGamesUserHasCreated;
- (IBAction)cameraButtonTapped;
- (IBAction)logUserOut;
- (IBAction)showLeaderboards;
- (void)uploadImage:(NSData *)imageData;
- (void)refreshImage;


@end

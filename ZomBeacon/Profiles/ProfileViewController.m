//
//  ProfileViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/17/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    //GameCenter user authentication
    [self authenticateLocalUser];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 2.0f;
    self.profileImage.layer.borderColor = [[UIColor colorWithRed:1 green:0.74 blue:0.27 alpha:1] CGColor];
    
    currentUser = [PFUser currentUser];
    [self refreshImage];
    [super viewDidLoad];
    
    [self refreshList];
    
    [self setProfileValues];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshImage];
    [self setProfileValues];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)refreshList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getGamesUserHasCreated];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)setProfileValues
{
    self.userName.text = currentUser.username;
    self.realName.text = currentUser[@"name"];
    self.emailAddress.text = currentUser.email;
    self.shortBio.text = currentUser[@"bio"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
    [query whereKey:@"user" equalTo:currentUser];
    PFObject *theUserScore = [query getFirstObject];
    
    NSNumber *publicScore = theUserScore[@"publicScore"];
    NSNumber *privateScore = theUserScore[@"privateScore"];
    NSNumber *scoreTotal = [NSNumber numberWithFloat:([publicScore floatValue] + [privateScore floatValue])];
    
    self.userScore.text = [NSString stringWithFormat:@"%@ pts", scoreTotal];
    
    //Sets the score values in the GameCenter leaderboards
    [self reportScore:[publicScore intValue] forLeaderboardID:@"publicScore"];
    [self reportScore:[privateScore intValue] forLeaderboardID:@"privateScore"];
    [self reportScore:[scoreTotal intValue] forLeaderboardID:@"overallScore"];
}

#pragma mark - Camera Methods

- (IBAction)cameraButtonTapped
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"PHOTO"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"From Library", @"From Camera", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"From Library"])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    if ([buttonTitle isEqualToString:@"From Camera"])
    {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
    [self uploadImage:imageData];
}

//Saves image to Parse under the user's account
-(void)uploadImage:(NSData *)imageData
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:currentUser];
    PFFile *file = [[query getFirstObject] objectForKey:@"imageFile"];
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    if (!file)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Save PFFile
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    // Create a PFObject around a PFFile and associate it with the current user
                    PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
                    [userPhoto setObject:imageFile forKey:@"imageFile"];
                    
                    [userPhoto setObject:currentUser forKey:@"user"];
                    
                    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                        
                        if (!error)
                        {
                            [self refreshImage];
                        }
                    }];
                }
            }];
        });
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
                    [query whereKey:@"user" equalTo:currentUser];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *objects, NSError *error) {
                        if (!error)
                        {
                            PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
                            [objects setObject:imageFile forKey:@"imageFile"];
                            [objects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                });
                                if (!error)
                                {
                                    [self refreshImage];
                                }
                            }];
                        }
                    }];
                }
            }];
        });
        [self refreshImage];
    }
}

- (void)refreshImage
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:currentUser];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *file = object[@"imageFile"];
        self.profileImage.file = file;
        [self.profileImage loadInBackground];
    }];
}

#pragma mark - Table View Methods

- (NSMutableArray *)getGamesUserHasCreated
{
    self.privateGames = nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"hostUser" equalTo:currentUser];
    [query includeKey:@"hostUser"];
    [query orderByAscending:@"dateTime"];
    self.privateGames = [[query findObjects] mutableCopy];
    
    return self.privateGames;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.privateGames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"gameCell";
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *game = self.privateGames[indexPath.row];
    cell.gameName.text = game[@"gameName"];
    cell.gameDate.text = game[@"dateTime"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *game = self.privateGames[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamedetails"];
    
    vc.gameDateString = game[@"dateTime"];
    vc.gameNameString = game[@"gameName"];
    PFGeoPoint *gameLocation = game[@"location"];
    CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
    vc.gameLocationCoord = gameLocationCoords;
    vc.gameIdString = game.objectId;
    
    PFObject *hostUser = game[@"hostUser"];
    vc.gameHostString = hostUser[@"name"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//Allowing the deletion of cells
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//Setting up what happens when you tap delete on a cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        PFObject *gameToBeDeleted = [self.privateGames objectAtIndex:indexPath.row];
        [gameToBeDeleted deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self getGamesUserHasCreated];
                [self.tableView reloadData];
            }
        }];
    }
}

//Method that logs the user out with the Parse framework
- (IBAction)logUserOut
{
    [currentUser setObject:[NSNull null] forKey:@"location"];
    [currentUser save];
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - GameCenter Implementation

- (void)authenticateLocalUser
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            [self presentViewController:viewController animated:YES completion:nil];
        }
    };
}

- (IBAction)showLeaderboards
{
    GKGameCenterViewController *vc = [[GKGameCenterViewController alloc] init];
    if (vc != NULL)
    {
        vc.gameCenterDelegate = self;
        //Controls which state of the view you want to show
        vc.viewState = GKGameCenterViewControllerStateLeaderboards;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier
{
	GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
	scoreReporter.value = score;
    
	[GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error)
        {
           //Didn't report.
        }
    }];
}

#pragma mark - Closing methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  PublicSurvivorViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PublicSurvivorViewController.h"

@interface PublicSurvivorViewController ()

@end

@implementation PublicSurvivorViewController

- (void)viewDidLoad
{
    currentUser = [PFUser currentUser];
    [self queryNearbyUsers];
    
    [super viewDidLoad];
    
    //Beacon & MapView stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.navigationItem.hidesBackButton = YES;
    self.mapView.delegate = self;
    
    mapKeyShowing = NO;
    
    //Setting up beacon for sending headshots
    NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString:@"6170CEEF-4D17-4741-8068-850A601E32F0"];
    CLBeaconMajorValue major = [currentUser[@"major"] unsignedShortValue];
    CLBeaconMajorValue minor = [currentUser[@"minor"] unsignedShortValue];
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2 major:major minor:minor identifier:@"com.zombeacon.publicRegion"];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStylePlain target:self action:@selector(backHome)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    //NSNotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(invalidateTimer) name:UIApplicationDidEnterBackgroundNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(validateTimer) name:UIApplicationDidBecomeActiveNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isSurvivor" object:nil userInfo:nil];
}

- (void)backHome
{
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[MainMenuViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //MapView stuff
    [self zoomToUserLocation:self.locationManager.location];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self invalidateTimer];
}

- (void)invalidateTimer
{
    [self.queryTimer invalidate];
}

- (void)validateTimer
{
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

//Queries all nearby users and adds them to the mapView
- (void)queryNearbyUsers
{
    PFGeoPoint *userGeoPoint = currentUser[@"location"];
    PFQuery *query = [PFUser query];
    [query whereKey:@"joinedPublic" equalTo:@"YES"];
    [query whereKey:@"objectId" notEqualTo:currentUser.objectId];
    [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.25];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error)
        {
            // First remove all annotations to refresh the status of them
            UserAnnotations *newAnnotation;
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            //Start at int = 1 so that the query doesn't include yourself
            for (int i = 0; i < users.count ; i++)
            {
                PFGeoPoint *geoPointsForNearbyUser = users[i][@"location"];
                NSString *nameOfNearbyUser = users[i][@"username"];
                NSString *statusOfNearbyUser = users[i][@"publicStatus"];
                
                // Set some coordinates for our position
                CLLocationCoordinate2D location;
                location.latitude = (double) geoPointsForNearbyUser.latitude;
                location.longitude = (double) geoPointsForNearbyUser.longitude;
                
                if ([statusOfNearbyUser isEqualToString:@"survivor"])
                {
                    newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"survivor_annotation3"]];
                    
                }
                else if ([statusOfNearbyUser isEqualToString:@"zombie"])
                {
                    newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"zb_annotation"]];
                }
                
                [self.mapView addAnnotation:newAnnotation];
            }
        }
    }];
    
}

//Adds annotations to the mapView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[UserAnnotations class]])
    {
        UserAnnotations *userLocations = (UserAnnotations *)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"UserLocations"];
        
        if (annotationView == nil)
        {
            annotationView = userLocations.annotationView;
        }
        else
        {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Location Management

//Method to zoom to the user location
- (void)zoomToUserLocation:(CLLocation *)userLocation
{
    if (userLocation)
    {
        double miles = 0.25;
        double scalingFactor = ABS( (cos(2 * M_PI * userLocation.coordinate.latitude / 360.0) ));
        
        MKCoordinateSpan span;
        span.latitudeDelta = miles/69.0;
        span.longitudeDelta = miles/(scalingFactor * 69.0);
        
        MKCoordinateRegion region;
        region.center = userLocation.coordinate;
        region.span = span;
        [self.mapView setRegion:region animated:YES];
    }
}

- (IBAction)showMapKey
{
    if (mapKeyShowing == NO)
    {
        [UIView animateWithDuration:0.5 animations:^{self.mapKeyView.alpha = 1.0;}];
        mapKeyShowing = YES;
    }
    else if (mapKeyShowing == YES)
    {
        [UIView animateWithDuration:0.5 animations:^{self.mapKeyView.alpha = 0.0;}];
        mapKeyShowing = NO;
    }
}

//For the compass button on the map
- (IBAction)trackMyOrientation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 1.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 0.0;}];
}

//For the crosshairs button on the map
- (IBAction)centerMapOnLocation
{
    [self zoomToUserLocation:self.locationManager.location];
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 0.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 1.0;}];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 1.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 0.0;}];
}

#pragma mark - Beacon Management

//Method that starts advertising the headshot
- (IBAction)headshotTheZombie:(id)sender
{
    [self playHeadshotSound];
    self.beaconPeripheralData = [self.beaconRegion2 peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self.headshotButton setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(stopTheHeadshot) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(enableHeadshotButton) userInfo:nil repeats:NO];
}

//Method that stops advertising the headshot beacon
- (void)stopTheHeadshot
{
    [self.peripheralManager stopAdvertising];
}

- (void)enableHeadshotButton
{
    [self.headshotButton setEnabled:YES];
    [self playReloadSound];
}

- (void)playHeadshotSound
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"gun_shot" withExtension: @"wav"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer play];
}

- (void)playReloadSound
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"reload" withExtension: @"wav"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer play];
}

//Method that tracks the beacon activity
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - Closing Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end


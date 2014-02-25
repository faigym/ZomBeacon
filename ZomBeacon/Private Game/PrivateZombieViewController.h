//
//  PrivateZombieViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "UserAnnotations.h"
#import "PrivateDeadViewController.h"

@interface PrivateZombieViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, MKMapViewDelegate>
{
    PFUser *currentUser;
}

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion2;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSTimer *queryTimer;
@property (nonatomic, weak) IBOutlet UILabel *survivorCount;
@property (nonatomic, weak) IBOutlet UILabel *zombieCount;

- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;
- (IBAction)startInfecting:(id)sender;

@end

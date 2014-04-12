//
//  BeaconAdvertisingService.h
//  WaitList
//
//  Created by Chris Wagner on 8/11/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@import CoreLocation;

@interface BeaconAdvertisingService : NSObject

/*******************************************************************************
 ------ REMARK ------
 Add below code initially - prevent No BlueTooth Alert at the beginning
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
    [BeaconAdvertisingService sharedInstance];
 }
*******************************************************************************/

@property (nonatomic, readonly, getter = isAdvertising) BOOL advertising;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

+ (BeaconAdvertisingService *)sharedInstance;

- (void)startAdvertisingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;
- (void)stopAdvertising;

@end

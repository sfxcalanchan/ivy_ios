//
//  BeaconMonitoringService.m
//  Aroma
//
//  Created by Chris Wagner on 8/12/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "BeaconMonitoringService.h"

@interface BeaconMonitoringService()

@end

@implementation BeaconMonitoringService {
}


+ (BeaconMonitoringService *)sharedInstance {
    static dispatch_once_t onceToken;
    static BeaconMonitoringService *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    return self;
}

- (void)startMonitoringBeaconWithUUID:(NSUUID *)uuid
                                major:(CLBeaconMajorValue)major
                                minor:(CLBeaconMinorValue)minor
                           identifier:(NSString *)identifier
                              onEntry:(BOOL)entry
                               onExit:(BOOL)exit
{
    if (major && minor){
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
    }
    else if (major){
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major identifier:identifier];
    }
    else{
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    }
    
    self.beaconRegion.notifyOnEntry = entry;
    self.beaconRegion.notifyOnExit = exit;
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)stopMonitoringAllRegions {
    
    NSLog(@"0stopMonitoringAllRegions");
    
    if ( self.beaconRegion != nil){
        [self.locationManager stopMonitoringForRegion:self.beaconRegion];
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
    
//    for (CLRegion *region in self.locationManager.monitoredRegions) {
//        [self.locationManager stopMonitoringForRegion:region];
//    }
//    for (CLRegion *region in self.locationManager.monitoredRegions) {
//        if ( [region isKindOfClass:[CLBeaconRegion class]]){
//            [self.locationManager stopMonitoringForRegion:region];
//        }
//    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ( [region isKindOfClass:[CLBeaconRegion class]]){
        CLBeaconRegion *beaconRegion = (CLBeaconRegion*)region;
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        
         /************************ Sender Notification Example *********************************/
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.userInfo = @{@"uuid": beaconRegion.proximityUUID.UUIDString};
//        notification.alertBody = [NSString stringWithFormat:@"Looks like you're near %@!", beaconRegion.proximityUUID.UUIDString];
//        notification.soundName = @"Default";
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidEnterRegion" object:self userInfo:@{@"beaconRegion": beaconRegion}];
        
        
        /************************ Receiver Notification Example *********************************/
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidEnterRegionNotification:) name:@"DidEnterRegion" object:nil];
//        
//        - (void)handleDidEnterRegionNotification:(NSNotification *)note {
//            CLBeaconRegion *beaconRegion = note.userInfo[@"beaconRegion"];
//            NSLog(@"handleDidEnterRegionNotification : %@", beaconRegion.proximityUUID.UUIDString);
//            
//            UIAlertView *beaconIssueAlert = [[UIAlertView alloc] initWithTitle:@"EnterRegion Issue" message:[NSString stringWithFormat:@"handleDidEnterRegionNotification : %@", beaconRegion.proximityUUID.UUIDString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [beaconIssueAlert show];
//        }

    }
    
    NSLog(@"Beacon didEnterRegion");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ( [region isKindOfClass:[CLBeaconRegion class]]){
        CLBeaconRegion *beaconRegion = (CLBeaconRegion*)region;
        [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
        
//        UILocalNotification *notification = [[UILocalNotification alloc]init];
//        notification.userInfo = @{@"uuid": beaconRegion.proximityUUID.UUIDString};
//        notification.alertBody = [NSString stringWithFormat:@"Well you are far from %@!", beaconRegion.proximityUUID.UUIDString];
//        notification.soundName = @"Default";
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidExitRegion" object:self userInfo:@{@"beaconRegion": beaconRegion}];
        
    }
    NSLog(@"Beacon didExitRegion");
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
//    CLBeacon *beacon = [[CLBeacon alloc] init];
//    beacon = [beacons lastObject];
    for (CLBeacon *foundBeacon in beacons) {
        NSLog(@"Beacon proximityUUID : %@", foundBeacon.proximityUUID.UUIDString);
        NSLog(@"Beacon Major : %@", foundBeacon.major);
        NSLog(@"Beacon Minor : %@", foundBeacon.minor);
        NSLog(@"Beacon Accuracy : %@", [NSString stringWithFormat:@"%f", foundBeacon.accuracy]);
        NSLog(@"Beacon rssi : %@", [NSString stringWithFormat:@"%i", foundBeacon.rssi]);

        switch (foundBeacon.proximity) {
            case CLProximityUnknown:
                NSLog(@"Beacon Proximity: Unknown Proximity");
                break;
                
            case CLProximityImmediate:
                NSLog(@"Beacon Proximity: Immediate");
                break;
                
            case CLProximityNear:
                NSLog(@"Beacon Proximity: Near");
                break;
                
            case CLProximityFar:
                NSLog(@"Beacon Proximity: Far");
                break;
                
            default:
                break;
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceivedRangeBeacons" object:self userInfo:@{@"beacon": foundBeacon}];
    }
    
}

@end

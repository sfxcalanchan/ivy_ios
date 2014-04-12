//
//  BeaconAdvertisingService.m
//  WaitList
//
//  Created by Chris Wagner on 8/11/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "BeaconAdvertisingService.h"

@import CoreBluetooth;

//NSString * const kBeaconIdentifier = @"com.razeware.waitlist";
NSString * const kBeaconIdentifier = @"com.toothybuddies.letter_formation";


@interface BeaconAdvertisingService () <CBPeripheralManagerDelegate>

@property (nonatomic, readwrite, getter = isAdvertising) BOOL advertising;

@end

@implementation BeaconAdvertisingService {    
}

+ (BeaconAdvertisingService *)sharedInstance {
    static BeaconAdvertisingService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    /***************** For disable the turn on BlueTooth Alert Message Used Start *************************/
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerOptionShowPowerAlertKey, nil];
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:options];
    /***************** For disable the turn on BlueTooth Alert Message Used End *************************/
//    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ];
    
    return self;
}

- (void)startAdvertisingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    NSError *bluetoothStateError = nil;
    
//    if (![self bluetoothStateValid:&bluetoothStateError]) {
//        [[[UIAlertView alloc] initWithTitle:@"Bluetooth Issue" message:bluetoothStateError.userInfo[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        return;
//    }
    
//    CLBeaconRegion *region;
    if (uuid && major && minor) {
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:kBeaconIdentifier];
    } else if (uuid && major) {
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major identifier:kBeaconIdentifier];
    } else if (uuid) {
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kBeaconIdentifier];
    } else {
        [NSException raise:@"You must at least provide a UUID to start advertising" format:nil];
    }
    
    /*************************************************************************************************************************************
     1. region peripheralDataWithMeasuredPower:(measuredPower)
     
        - measuredPower passed should represent the expected RSSI at a distance of 1 meter.
        - So, if you calibrated your environment and found that when a receiving device is 1 meter away from the beacon it reads an average RSSI value of -35, you would set this value to -35.
     
     2. To get the RSSI at a distance of 1 meter. Try to set the below function
     
         -(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
             CLBeacon *beacon = [[CLBeacon alloc] init];
             beacon = [beacons lastObject];
             
             self.beaconFoundLabel.text = @"Yes";
             self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
             self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
             self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
             self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
     
             if (beacon.proximity == CLProximityUnknown) {
                 self.distanceLabel.text = @"Unknown Proximity";
             } else if (beacon.proximity == CLProximityImmediate) {
                 self.distanceLabel.text = @"Immediate";
             } else if (beacon.proximity == CLProximityNear) {
                 self.distanceLabel.text = @"Near";
             } else if (beacon.proximity == CLProximityFar) {
                 self.distanceLabel.text = @"Far";
             }
     
             self.rssiLabel.text = [NSString stringWithFormat:@"%i", beacon.rssi];
         }
     ************************************************************************************************************************************/
    
//    NSDictionary *peripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    NSDictionary *peripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:[NSNumber numberWithInt:-60]];
    [self.peripheralManager startAdvertising:peripheralData];
}

- (void)stopAdvertising {
    [self.peripheralManager stopAdvertising];
    self.advertising = NO;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSError *bluetoothStateError = nil;
    if (![self bluetoothStateValid:&bluetoothStateError]) {
        NSLog(@"peripheralManagerDidUpdateState error");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *bluetoothIssueAlert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Issue" message:bluetoothStateError.userInfo[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [bluetoothIssueAlert show];
        });
    }
}


/****************** Call when [_peripheralManager startAdvertising] method called  *******************/
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"peripheralManagerDidStartAdvertising error");
            [[[UIAlertView alloc] initWithTitle:@"Cannot Advertise Beacon" message:@"There was an issue starting the advertisement of your beacon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Start Advertising Error: %@", error);
        } else {
            NSLog(@"Advertising!");
            self.advertising = YES;
        }
    });
}

- (BOOL)bluetoothStateValid:(NSError **)error {
    BOOL bluetoothStateValid = YES;
    
    NSLog(@"Check bluetoothStateValid");
    
    switch (self.peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOff:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStatePoweredOff
                                         userInfo:@{@"message": @"You must turn Bluetooth on in order to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateResetting:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateResetting
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnauthorized:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnauthorized
                                         userInfo:@{@"message": @"This application is not authorized to use Bluetooth, verify your settings or check with your device's administrator"}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnknown:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnknown
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnsupported:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnsupported
                                         userInfo:@{@"message": @"Your device does not support Bluetooth. You will not be able to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStatePoweredOn:
            bluetoothStateValid = YES;
            break;
    }
    
    return bluetoothStateValid;
}

@end

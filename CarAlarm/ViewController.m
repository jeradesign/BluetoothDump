//
//  ViewController.m
//  CarAlarm
//
//  Created by John Brewer on 4/6/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self logMessage:[[NSDate date] description]];
    [self startConnection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Bluetooth stuff

- (void)startConnection
{
    [self logMessage:@"startConnection"];
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)resetConnection
{
    [self logMessage:@"resetConnection"];
    // TODO: invalidate all connections.
}

- (void)openConnection
{
    [self logMessage:@"openConnection"];
    NSArray *services = @[ [CBUUID UUIDWithString:@"FFE1"]];
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self logMessage:[NSString stringWithFormat:@"centralManagerDidUpdateState:%d", central.state]];
    if (self.connected && central.state < CBCentralManagerStatePoweredOn) {
        [self resetConnection];
    } else if (!self.connected && central.state >= CBCentralManagerStatePoweredOn) {
        [self openConnection];
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    [self logMessage:peripheral.name];
    [self logMessage:(__bridge NSString *)(CFUUIDCreateString(NULL, peripheral.UUID))];
    if ([peripheral.name isEqualToString:@"TI BLE Sensor Tag"] && !self.found) {
        [self logMessage:@"SensorTag Found!"];
        self.found = TRUE;
        [self.manager stopScan];
        self.peripheral = peripheral; // Otherwise gets released
        [self.manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self logMessage:[NSString stringWithFormat:@"connected to %@", peripheral.name]];
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    [self logMessage:[NSString stringWithFormat:@"failed to connect to %@: %@",
                      peripheral.name,
                      error]];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error;
{
    [self logMessage:[NSString stringWithFormat:@"disconnected from %@: %@",
                      peripheral.name,
                      error]];    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self logMessage:[NSString stringWithFormat:@"services for %@", peripheral.name]];
    for (CBService *service in peripheral.services) {
        NSString *UUIDString = CFBridgingRelease(CFUUIDCreateString(NULL, CFBridgingRetain(service.UUID)));
        
        [self logMessage:[NSString stringWithFormat:@"%@: %@", UUIDString, service.debugDescription]];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSString *UUIDString = CFBridgingRelease(CFUUIDCreateString(NULL, CFBridgingRetain(service.UUID)));
    
    [self logMessage:[NSString stringWithFormat:@"%@: %@", UUIDString, service.debugDescription]];

    for (CBCharacteristic *characteristic in service.characteristics) {
        NSString *cUUIDString = CFBridgingRelease(CFUUIDCreateString(NULL, CFBridgingRetain(characteristic.UUID)));
        
        [self logMessage:[NSString stringWithFormat:@"    %@: %@", cUUIDString, characteristic.debugDescription]];
    }    
}

- (void)logMessage:(NSString *)message
{
    self.log.text = [self.log.text stringByAppendingFormat:@"%@\n", message];
    NSLog(@"%@", message);
}

@end

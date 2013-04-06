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
    [self.manager connectPeripheral:peripheral options:nil];
}

- (void)logMessage:(NSString *)message
{
    self.log.text = [self.log.text stringByAppendingFormat:@"%@\n", message];
}

@end

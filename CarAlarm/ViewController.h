//
//  ViewController.h
//  CarAlarm
//
//  Created by John Brewer on 4/6/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UITextView *log;

@property (nonatomic) CBCentralManager *manager;
@property (nonatomic) CBPeripheral *peripheral;
@property (nonatomic) BOOL connected;

@end

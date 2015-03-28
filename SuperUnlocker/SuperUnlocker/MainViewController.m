//
//  MainViewController.m
//  SuperUnlocker
//
//  Created by Vladimir Hudnitsky on 3/21/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MainViewController()

@property (nonatomic, strong) AVAudioPlayer *player;

@end


@implementation MainViewController
@synthesize sendBtn;


- (void)viewDidLoad
{
    [super viewDidLoad];
    centmanager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:@"sound" withExtension:@"caf"];
    
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [self.player setNumberOfLoops:100];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        //Make sure the system follows our playback status
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        //Load the audio into memory
        [self.player play];
    }
}

- (IBAction)disconnect:(id)sender {
    [centmanager cancelPeripheralConnection:aCperipheral];
}


//start scan for server
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"0");
            [centmanager scanForPeripheralsWithServices:
                    @[
                            [CBUUID UUIDWithString:@"FC44DD96-71BC-DFB0-BA4D-9B0D5089A3EB"],
                            [CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]
                    ] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
            break;

        default:
            NSLog(@"%i",central.state);
            break;
    }
}

//start to connect to server
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([RSSI floatValue]>=-60.f) {
        NSLog(@"1");
        [central stopScan];
        aCperipheral = aPeripheral;
        [central connectPeripheral:aCperipheral options:nil];

    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed:%@",error);
}

//connected to peripheral
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"Connected:%p",aPeripheral.UUID);
    NSLog(@"2");
    [aCperipheral setDelegate:self];
    [aCperipheral discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    NSLog(@"3");
    for (CBService *aService in aPeripheral.services){
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]]) {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Finish Write\n");
    NSLog(@"5");
//    [TextView insertText:@"Finish Write\n"];
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSData *updatedValue = characteristic.value;
    NSLog(@"%@", [[NSString alloc] initWithData:updatedValue encoding:NSUTF8StringEncoding]);
    if ([[[NSString alloc] initWithData:updatedValue encoding:NSUTF8StringEncoding] isEqualToString:@"ENDAL"]) {
        [centmanager cancelPeripheralConnection:aPeripheral];
//        [TextView insertText:[NSString stringWithFormat:@"%@\n", [[NSJSONSerialization JSONObjectWithData:finaldata options:kNilOptions error:nil] description]]];
    } else {
//        [finaldata appendData:updatedValue];
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"4");
    for (CBCharacteristic *aChar in service.characteristics) {
        NSLog(@"%@", aChar.UUID);
//            [TextView insertText:[NSString stringWithFormat:@"Characteristic UUID:%@\n", aChar.UUID]];
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA18"]]) {
            NSLog(@"%lu", aChar.properties);
//                [TextView insertText:[NSString stringWithFormat:@"Characteristic Prop:%lu\n", aChar.properties]];
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA17"]]) {
            //NSLog(@"Find DA17");
            NSLog(@"%lu", aChar.properties);
//                [TextView insertText:[NSString stringWithFormat:@"Characteristic Prop:%lu\n", aChar.properties]];
            NSString *mainString = [NSString stringWithFormat:@"ping"];
            NSData *mainData = [mainString dataUsingEncoding:NSUTF8StringEncoding];
            [aPeripheral writeValue:mainData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA16"]]) {
            NSLog(@"Find DA16");
            NSLog(@"%lu", aChar.properties);
//                [TextView insertText:[NSString stringWithFormat:@"Characteristic Prop:%lu\n", aChar.properties]];
//                [aPeripheral readValueForCharacteristic:aChar];
        }
    }

}

- (void)willEnterBackgroud{
    [centmanager stopScan];
}

- (void)willBacktoForeground{
    [centmanager scanForPeripheralsWithServices:nil options:nil];
}

- (IBAction)clickToSend:(id)sender {
    [centmanager scanForPeripheralsWithServices:
            @[
                    [CBUUID UUIDWithString:@"FC44DD96-71BC-DFB0-BA4D-9B0D5089A3EB"],
                    [CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]
            ] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end

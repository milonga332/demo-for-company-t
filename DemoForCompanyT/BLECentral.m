#import <Foundation/Foundation.h>
#import "BLECentral.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString* const ServiceUUID = @"1fee6acf-a826-4e37-9635-4d8a01642c5d";
NSString* const CharacteristicUUID = @"7691b78a-9015-4367-9b95-fc631c412cc6";

@interface BLECentral () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (weak) id<BLECentralDelegate> delegate;
@property CBCentralManager* manager;
@property CBPeripheral* peripheral;
@property BOOL isStarted;
@end

@implementation BLECentral

- (id)initWithDelegate:(id<BLECentralDelegate>)delegate
{
    self = [super init];
    _delegate = delegate;
    _manager = [[CBCentralManager alloc] initWithDelegate:self
                                                    queue:dispatch_queue_create([@"DEMO" UTF8String], DISPATCH_QUEUE_SERIAL)];
    return self;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    if(CBManager.authorization != CBManagerAuthorizationAllowedAlways){
        [_delegate updateBLEStatus:@"invalid authorization"];
        return;
    }
    
    if(_manager.state != CBManagerStatePoweredOn){
        [_delegate updateBLEStatus:@"power is off"];
        return;
    }
    
    if(_isStarted){
        return;
    }
    
    [_manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ServiceUUID]]
                                         options:@{
                                             CBCentralManagerScanOptionAllowDuplicatesKey : @YES
                                         }];
    _isStarted = YES;
    [_delegate updateBLEStatus:@"scanning"];
}

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    _peripheral = peripheral;
    [_manager stopScan];
    [_manager connectPeripheral:peripheral options:nil];
    [_delegate updateBLEStatus:@"connecting"];
}

- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:ServiceUUID]]];
    [_delegate updateBLEStatus:@"discovering services"];
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    if (error) {
        [_delegate updateBLEStatus:[NSString stringWithFormat:@"error: %@", error]];
        return;
    }

    for (CBService* service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:ServiceUUID]]) {
            [peripheral discoverCharacteristics:@[ [CBUUID UUIDWithString:CharacteristicUUID]]
                                     forService:service];
            [_delegate updateBLEStatus:@"discovering characteristics"];
        }
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
    if (error) {
        [_delegate updateBLEStatus:[NSString stringWithFormat:@"error: %@", error]];
        return;
    }

    for (CBCharacteristic* characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CharacteristicUUID]]) {
            [_delegate updateBLEStatus:[NSString stringWithFormat:@"battery: %@", characteristic.value]];
        }
    }
}

- (void)centralManager:(CBCentralManager*)central didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    [_delegate updateBLEStatus:@"didFailToConnectPeripheral"];
}

- (void)centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    [_delegate updateBLEStatus:@"didDisconnectPeripheral"];
}

@end

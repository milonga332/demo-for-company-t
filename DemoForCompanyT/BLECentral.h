


@protocol BLECentralDelegate
- (void)updateBLEStatus:(NSString*)status;
@end


/*
 This class contains all BLE-related functions for demo, including scanning, connecting, and...etc.
 
 If it's for production, I'd prefer to implement it with "State Pattern", which means all the states will be separated into several different classes for better maintainability. (like ScanningState, ConnectingState, and ...etc)
 */
@interface BLECentral : NSObject
- (id)initWithDelegate:(id<BLECentralDelegate>)delegate;
- (void)start;
@end


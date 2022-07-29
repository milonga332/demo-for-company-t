


@protocol BLECentralDelegate
- (void)updateBLEStatus:(NSString*)status;
@end



@interface BLECentral : NSObject
- (id)initWithDelegate:(id<BLECentralDelegate>)delegate;
@end


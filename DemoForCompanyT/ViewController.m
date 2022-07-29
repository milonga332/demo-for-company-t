//
    

#import "ViewController.h"
#import "BLECentral.h"

@interface ViewController () <BLECentralDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property BLECentral *central;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _central = [[BLECentral alloc] initWithDelegate:self];
}

- (void)updateBLEStatus:(NSString*)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = status;
    });
}

@end

//
//  AccelerometerViewController.h
//  Accelerometer
//
//  Created by Joseph Conway on 19/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AccelerometerViewController : UIViewController <UIAccelerometerDelegate>{
	IBOutlet UILabel *xLabel;
	IBOutlet UILabel *yLabel;
	IBOutlet UILabel *zLabel;
	NSMutableArray *plots;
	NSMutableArray *totals;
}
@property(nonatomic, retain) NSMutableArray *plots;
@property(nonatomic, retain) NSMutableArray *totals;
@property(strong, nonatomic) CMMotionManager *motionManager;

-(IBAction)screenTouched;
@end


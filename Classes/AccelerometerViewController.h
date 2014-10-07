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
  IBOutlet UITextField *gestureName;
	NSMutableArray *plots;
  NSString *dataFilePath;
}
@property(nonatomic, retain) NSMutableArray *plots;
@property(strong, nonatomic) CMMotionManager *motionManager;
@property(nonatomic, retain) NSString *dataFilePath;

-(IBAction)clearAll;
-(IBAction)captureGesture;
-(IBAction)save;
-(IBAction)deleteAll;
@end


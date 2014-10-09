//
//  AccelerometerViewController.h
//  Accelerometer
//
//  Created by Joseph Conway on 19/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#define BUFFER_SIZE 64


@interface AccelerometerViewController : UIViewController <UIAccelerometerDelegate>{
  IBOutlet UITextField *gestureName;
  IBOutlet UITextField *predictResult;
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
-(IBAction)train;
-(IBAction)predict;


@end


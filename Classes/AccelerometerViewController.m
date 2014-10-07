//
//  AccelerometerViewController.m
//  Accelerometer
//
//  Created by Joseph Conway on 19/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AccelerometerViewController.h"

@implementation AccelerometerViewController
@synthesize plots, dataFilePath;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

  self.dataFilePath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"capture.data"];

  self.motionManager = [[CMMotionManager alloc] init];
  self.motionManager.accelerometerUpdateInterval = 0.01;
  self.motionManager.gyroUpdateInterval = 0.01;

	self.plots = [NSMutableArray arrayWithCapacity:100];
}

- (void)captureGesture
{
  NSLog(@"capture gesture");

  [gestureName resignFirstResponder];

  [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(startCapture:) userInfo:gestureName.text repeats:NO];
}

- (void)startCapture:(NSTimer *)timer
{
  NSLog(@"Start capture %@", [timer userInfo]);

  [self clearData];

  [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
    [self.plots insertObject:motion atIndex:0];
    [[self view] setNeedsDisplay];
  }];

  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(endCapture:) userInfo:[timer userInfo] repeats:NO];
}

- (void)endCapture:(NSTimer *)timer
{
  [self.motionManager stopDeviceMotionUpdates];
  NSLog(@"End captured %@", [timer userInfo]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)clearData
{
  self.plots = [NSMutableArray arrayWithCapacity:100];
  [[self view] setNeedsDisplay];
}

-(IBAction)clearAll
{
	self.plots = [NSMutableArray arrayWithCapacity:100];
  gestureName.text = @"";
	[[self view] setNeedsDisplay];
}

-(NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(IBAction)deleteAll
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL success = false;
  NSError *error;

  if ([fileManager fileExistsAtPath:self.dataFilePath]) {
    success = [fileManager removeItemAtPath:self.dataFilePath error:&error];
    if (success) {
      NSString *msg = [NSString stringWithFormat:@"Deleted file %@", self.dataFilePath];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
    else {
      NSString *msg = [NSString stringWithFormat:@"Could not delete %@", self.dataFilePath];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
  }
}

-(IBAction)save
{
  NSMutableString *output = [[NSMutableString alloc] initWithFormat:@"%@|", [gestureName text]];
  for (unsigned long i=[self.plots count]-1; i>0; i--) {
    CMDeviceMotion *motion = [self.plots objectAtIndex:i];
    [output appendFormat:@"%f,%f,%f,%f,%f,%f,%f,%f,%f|",
     motion.userAcceleration.x,
     motion.userAcceleration.y,
     motion.userAcceleration.z,
     motion.rotationRate.x,
     motion.rotationRate.y,
     motion.rotationRate.z,
     motion.gravity.x,
     motion.gravity.y,
     motion.gravity.z];
  }
  [output appendString:@"\n"];

  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL success = false;
  if (![fileManager fileExistsAtPath:self.dataFilePath]) {
    success = [output writeToFile:self.dataFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"Created and wrote file %@", self.dataFilePath);
  }
  else {
    @try {
      NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.dataFilePath];
      [fileHandle seekToEndOfFile];
      [fileHandle writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
      success = true;
      NSLog(@"Appended capture %@ to file %@", [gestureName text], self.dataFilePath);
    }
    @catch (NSException *exception) {
      success = false;
      NSLog(@"Exception while trying to append file %@ : %@", self.dataFilePath, exception);
    }
  }

  if (!success) {
    NSLog(@"Unable to write file %@", self.dataFilePath);
    NSString *msg = [NSString stringWithFormat:@"Could not write file %@", self.dataFilePath];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}

- (void)dealloc {
	//[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [super dealloc];
}

@end

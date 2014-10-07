//
//  AccelerometerViewController.m
//  Accelerometer
//
//  Created by Joseph Conway on 19/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AccelerometerViewController.h"

@implementation AccelerometerViewController
@synthesize plots;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

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
  NSLog(@"Capture %@", [timer userInfo]);

  [self clearData];

  [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
    [self outputMotionData:motion];
  }];

  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(endCapture:) userInfo:[timer userInfo] repeats:NO];
}

- (void)endCapture:(NSTimer *)timer
{
  [self.motionManager stopDeviceMotionUpdates];
  NSLog(@"Captured %@", [timer userInfo]);
}

- (void)outputMotionData:(CMDeviceMotion*)motion
{
  [[self view] setNeedsDisplay];

  //NSLog(@"%@", motion);

  [self.plots insertObject:motion atIndex:0];
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

-(IBAction)save
{
  NSString *path = [[[self applicationDocumentsDirectory].path stringByAppendingPathComponent:gestureName.text] stringByAppendingString:@".data"];

  NSMutableString *output = [[NSMutableString alloc] initWithString:@""];
  for (unsigned long i=[self.plots count]-1; i>0; i--) {
    [output appendFormat:@"%@\n", [self.plots objectAtIndex:i]];
  }

  BOOL success = [output writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if (!success) {
    NSLog(@"Unable to write file %@", path);
    NSString *msg = [NSString stringWithFormat:@"Could not write file %@", path];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  else {
    NSLog(@"Wrote file %@", path);
    [self clearAll];
  }
}

- (void)dealloc {
	//[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [super dealloc];
}

@end

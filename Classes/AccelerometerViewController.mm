#import "AccelerometerViewController.h"

@implementation AccelerometerViewController
@synthesize plots, dataFilePath;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
  self.dataFilePath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"capture.data"];

  self.motionManager = [[CMMotionManager alloc] init];
  self.motionManager.deviceMotionUpdateInterval = 0.01;

	self.plots = [NSMutableArray arrayWithCapacity:BUFFER_SIZE];
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
    if ([self.plots count] < 256) {
      [self.plots insertObject:motion atIndex:0];
      [[self view] setNeedsDisplay];
    }
    else {
      [self.motionManager stopDeviceMotionUpdates];
    }
  }];

//  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(endCapture:) userInfo:[timer userInfo] repeats:NO];
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
  self.plots = [NSMutableArray arrayWithCapacity:BUFFER_SIZE];
  [[self view] setNeedsDisplay];
}

-(IBAction)clearAll
{
	self.plots = [NSMutableArray arrayWithCapacity:BUFFER_SIZE];
  gestureName.text = @"";
	[[self view] setNeedsDisplay];
}


-(IBAction)train
{
  
    NSString *filePath=[[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"capture.data"];
    NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];

    CvSVMParams params;
    params.svm_type = CvSVM::C_SVC;
    params.kernel_type = CvSVM::POLY;
    params.gamma = 20;
    params.degree = 1;
    params.coef0 = 0;
    
    params.C = 7;
    params.nu = 0.0;
    params.p = 0.0;
    
    params.class_weights = NULL;
    params.term_crit.type = CV_TERMCRIT_ITER +CV_TERMCRIT_EPS;
    params.term_crit.max_iter = 1000;
    params.term_crit.epsilon = 1e-6;
    
    CvSVM svm;
    
    float data[10] = {1,2,2,2,2,2,2,1,1,1};
    int sz[] = {10,10};
    cv::Mat training_mat = cv::Mat(2, sz, CV_32F);
    cv::Mat labels = cv::Mat(1,10,CV_32F, &data);
    std::cout << "M = "<< std::endl << " "  << labels << std::endl << std::endl;

    
    svm.train(training_mat, labels, cv::Mat(), cv::Mat(), params);
    
    NSString *modelPath=[[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"svm_model"];

    svm.save([modelPath cString]);
    
    svm.load([modelPath cString]);
    float result = svm.predict(labels);
    printf("result %f\n",result);
    
    for (NSString* line in lines) {
        if (line.length) {
            //NSLog(@"line: %@", line);
            NSArray *array = [line componentsSeparatedByString:@"|"];
            for( int i=0;i<[array count]; ++i){
                NSString* tick = [array objectAtIndex:i];
                NSArray * dofs = [tick componentsSeparatedByString:@","];
                for( int j=0;j<[dofs count]; ++j){
                    NSString* dof = [dofs objectAtIndex:j];
                    //NSLog(@"line: %@", line);
                    //printf("%s\n",[dof UTF8String]);
                }
            }
        }
    }
    
}

// /private/var/mobile/Containers/Bundle/Application/6C9A8F8F-060A-4D43-BE0F-B90175D8B4B9/Accelerometer.app/Documents/capture.data
//         /var/mobile/Containers/Data/Application/586E1909-812A-4652-A5FC-5A66AF4301BD/Documents/capture.data

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

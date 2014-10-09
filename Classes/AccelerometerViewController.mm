#import "AccelerometerViewController.h"
#import "Feature.h"


@implementation AccelerometerViewController
@synthesize plots, dataFilePath, modelPath;

using namespace std;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
  self.dataFilePath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"capture2.data"];
  self.modelPath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"svm_model"];

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
  predictResult.text = @"";
	[[self view] setNeedsDisplay];
}

void getDataFromFile(NSString *filePath, std::vector<std::vector<float> > &data, std::vector<float> &labels){
    NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
    

    
    for (NSString* line in lines) {
        if (line.length) {
            //NSLog(@"line: %@", line);
            NSArray *array = [line componentsSeparatedByString:@"|"];
            std::string label =[[array objectAtIndex:0] UTF8String];
            
            
            
            labels.push_back(stof(label));
            
            vector<vector<float> > raw;
            vector<float> x;
            vector<float> y;
            vector<float> z;
            vector<float> rx;
            vector<float> ry;
            vector<float> rz;
            
            for( int i=1;i<[array count]; ++i){
                NSString* tick = [array objectAtIndex:i];
                NSArray * dofs = [tick componentsSeparatedByString:@","];
                //printf("%s\n",[tick UTF8String]);
                if([dofs count]>=6){
                    x.push_back(stof([[dofs objectAtIndex:1] UTF8String]));
                    y.push_back(stof([[dofs objectAtIndex:2] UTF8String]));
                    z.push_back(stof([[dofs objectAtIndex:3] UTF8String]));
                    rx.push_back(stof([[dofs objectAtIndex:4] UTF8String]));
                    ry.push_back(stof([[dofs objectAtIndex:5] UTF8String]));
                    rz.push_back(stof([[dofs objectAtIndex:6] UTF8String]));
                }
            }
            raw.push_back(x);
            raw.push_back(y);
            raw.push_back(z);
            raw.push_back(rx);
            raw.push_back(ry);
            raw.push_back(rz);
            vector<float> feature = Feature::getTotalFeature(raw);
            data.push_back(feature);
            
        }
    }
}


CvSVMParams getConfiguredSVMParams(){
    CvSVMParams params;
    params.svm_type = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
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
    return params;
}


-(IBAction)train
{
  
    NSString *filePath=[[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"capture2.data"];
    std::vector<std::vector<float> > raw;
    std::vector<float> label;
    getDataFromFile(filePath, raw, label);
    
    CvSVMParams params = getConfiguredSVMParams();
    
    CvSVM svm;
    
    size_t N = raw.size();
    size_t M = raw[0].size();
    int sz[] = {N, M};
    
    cv::Mat training_mat = cv::Mat(2, sz, CV_32F);
    
    for(int i=0;i<N;i++)
    {
        for(int j=0;j<M;j++)
        {
            training_mat.at<float>(i, j) = raw[i][j];
        }
    }
    
    cv::Mat labels = cv::Mat(1,(int)label.size(),CV_32F, &label[0]);
    
    std::cout << "Data = "<< std::endl << " "  << training_mat << std::endl << std::endl;
    std::cout << "Label = "<< std::endl << " "  << labels << std::endl << std::endl;

    
    svm.train(training_mat, labels, cv::Mat(), cv::Mat(), params);
    
    svm.save([self.modelPath UTF8String]);
    
//    svm.load([modelPath cString]);
//    float result = svm.predict(labels);
    printf("Training done!\n");
    
    
}

-(IBAction)predict{
    CvSVMParams params = getConfiguredSVMParams();
    
    CvSVM svm;
    
    svm.load([self.modelPath UTF8String]);
    if([self.plots count]!=0){
      vector<vector<float> > raw= Feature::to2Dvector(self.plots);
      vector<float> feature= Feature::getTotalFeature(raw);
      cv::Mat featureMat = cv::Mat(1,(int)feature.size(),CV_32F, &feature[0]);;

      float result = svm.predict(featureMat);
      NSString *strResult = [NSString stringWithFormat:@"result %f",result];
      NSLog(@"%@",strResult);
      predictResult.text = strResult;
    }
}


// /private/var/mobile/Containers/Bundle/Application/6C9A8F8F-060A-4D43-BE0F-B90175D8B4B9/Accelerometer.app/Documents/capture.data
//         /var/mobile/Containers/Data/Application/586E1909-812A-4652-A5FC-5A66AF4301BD/Documents/capture.data

-(NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(IBAction)deleteData
{
  [self deleteFile:self.dataFilePath];
}

-(IBAction)deleteModel
{
  [self deleteFile:self.modelPath];
}

-(void)deleteFile:(NSString *)file
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL success = false;
  NSError *error;

  if ([fileManager fileExistsAtPath:file]) {
    success = [fileManager removeItemAtPath:file error:&error];
    if (success) {
      NSString *msg = [NSString stringWithFormat:@"Deleted file %@", file];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
    else {
      NSString *msg = [NSString stringWithFormat:@"Could not delete %@", file];
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

//
//  GraphView.m
//  Accelerometer
//
//  Created by Joseph Conway on 28/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "Feature.h"

using namespace std;

#define _AXIS_ORIGIN_X 20
#define _AXIS_ORIGIN_Y 225
#define _AXIS_LENGTH_X 460
#define _AXIS_LENGTH_Y -135

@implementation GraphView
@synthesize currentVC;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    self.filter = [[HighpassFilter alloc] initWithSampleRate:60 cutoffFrequency:5.0];

    //fftAccel = new FFT(BUFFER_SIZE);
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code.
    }
    self.filter = [[HighpassFilter alloc] initWithSampleRate:60 cutoffFrequency:5.0];
    
    //fftAccel = new FFT(BUFFER_SIZE);
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGFloat green[4] = {0.0f, 1.0f, 0.0f, 1.0f};
	CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
	CGFloat blue[4] = {0.0f, 0.0f, 1.0f, 1.0f};
    CGFloat yellow[4] = {1.0f,1.0f,0.0f,1.0f};
	CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
	
	//draw axis
    CGContextSetStrokeColor(c, white);
    CGContextBeginPath(c);
	//top of y axis
    CGContextMoveToPoint(c, _AXIS_ORIGIN_X, _AXIS_ORIGIN_Y+_AXIS_LENGTH_Y);
	//bottom of y axis
	CGContextAddLineToPoint(c, _AXIS_ORIGIN_X, _AXIS_ORIGIN_Y-_AXIS_LENGTH_Y);
	//origin
	CGContextMoveToPoint(c, _AXIS_ORIGIN_X, _AXIS_ORIGIN_Y);
	//end of x axis
    CGContextAddLineToPoint(c, _AXIS_ORIGIN_X+_AXIS_LENGTH_X, _AXIS_ORIGIN_Y);
	CGContextStrokePath(c);
	
	//draw arrow heads
    CGContextBeginPath(c);
    //Y-Axis up
	CGContextMoveToPoint(c, _AXIS_ORIGIN_X-4, _AXIS_ORIGIN_Y+_AXIS_LENGTH_Y+7);
	CGContextAddLineToPoint(c, _AXIS_ORIGIN_X, _AXIS_ORIGIN_Y+_AXIS_LENGTH_Y);
	CGContextAddLineToPoint(c, _AXIS_ORIGIN_X+4, _AXIS_ORIGIN_Y+_AXIS_LENGTH_Y+7);
	
	//X-axis right
	CGContextMoveToPoint(c, _AXIS_ORIGIN_X+_AXIS_LENGTH_X-5, _AXIS_ORIGIN_Y-4);
	CGContextAddLineToPoint(c, _AXIS_ORIGIN_X+_AXIS_LENGTH_X, _AXIS_ORIGIN_Y);
	CGContextAddLineToPoint(c, _AXIS_ORIGIN_X+_AXIS_LENGTH_X-5, _AXIS_ORIGIN_Y+4);
	CGContextStrokePath(c);
	
	//y-axis down
	CGContextMoveToPoint(c, _AXIS_ORIGIN_X-4, _AXIS_ORIGIN_Y-_AXIS_LENGTH_Y-7);
	CGContextAddLineToPoint(c, _AXIS_ORIGIN_X, _AXIS_ORIGIN_Y-_AXIS_LENGTH_Y);
	CGContextAddLineToPoint(c, _AXIS_ORIGIN_X+4, _AXIS_ORIGIN_Y-_AXIS_LENGTH_Y-7);
	CGContextStrokePath(c);
	
	
    if(currentVC.plots.count >5){
        vector<vector<float> > signal2D = Feature::to2Dvector(currentVC.plots);
        vector<vector<float> > filteredSignal2D = Feature::highpassFilter(currentVC.plots);
        vector<vector<float> > firstD = Feature::derivative(filteredSignal2D);
        vector<vector<float> > secondD = Feature::derivative(firstD);
        vector<vector<float> > thirdD = Feature::derivative(secondD);
        vector<vector<float> > fourthD = Feature::derivative(thirdD);
        
        
        vector<float> feature = Feature::getTotalFeature(signal2D);
        std::copy(feature.begin(), feature.end(), std::ostream_iterator<float>(std::cout, " "));
        cout<<endl;

        
        //plot points
        //rot rate x
        CGContextBeginPath(c);
        CGContextSetStrokeColor(c, red);
        CGContextSetFillColor(c, red);
        
        CGContextMoveToPoint(c, 20.0f, _AXIS_ORIGIN_Y);
        for (int i=1; i<fourthD.at(0).size(); i++) {
            if ((25+i) < _AXIS_LENGTH_X) {
                CGContextAddLineToPoint(c, _AXIS_ORIGIN_X+i, _AXIS_ORIGIN_Y - (80*fourthD[3][i]));
            }
        }
        
        CGContextStrokePath(c);
    }
    
    
    //Number of Samples for input(time domain)/output(frequency domain)
    //Must be Power of 2: 2^x
//    int numSamples = BUFFER_SIZE;
//
//    
//    //Output Array
//    float *frequency = (float *)malloc(sizeof(float)*numSamples);
//    
//    //Input Array
//    float *time = (float *)malloc(sizeof(float)*numSamples);
//    
//    
//    for (int i=0; i<numSamples; i++) {
//        time[i] = 0.0;
//    }
//    
//    for (int i=0; i<numSamples; i++) {
//        frequency[i] = 0.0;
//    }
//    
//
//    int size =[currentVC.plots count];
//    
//    NSLog(@"size: %d",size);
//    for (int i=0; i<MIN(size,BUFFER_SIZE); i++) {
//   //     for (int i=0; i<BUFFER_SIZE; i++) {
//
//       CMDeviceMotion *a = [currentVC.plots objectAtIndex:i];
//        time[i] = a.rotationRate.z;
//        
//       
//    }
//    
//    for (int i=0; i<numSamples; i++) {
//        NSLog(@"time: %d, amp: %.2f",i, time[i]);
//    }
//    
//        FFT *fftAccel = new FFT(BUFFER_SIZE);
//
//    fftAccel->doFFTReal(time, frequency, numSamples);
//    
//    for (int i=0; i<numSamples; i++) {
//        NSLog(@"index: %d, amp: %.2f",i, frequency[i]);
//    }
//    
//    delete [] frequency;
//    delete [] time;
//    
//    delete(fftAccel);

}




- (void)dealloc {
    [super dealloc];
    //delete(fftAccel);
}


@end

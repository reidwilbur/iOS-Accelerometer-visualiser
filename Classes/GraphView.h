//
//  GraphView.h
//  Accelerometer
//
//  Created by Joseph Conway on 28/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccelerometerViewController.h"
#import "MotionFilter.h"

#import "FFT.h"


@interface GraphView : UIView {
	AccelerometerViewController *currentVC;
    //HighpassFilter *filter;

   // FFT *fftAccel;
}

@property(nonatomic, retain)IBOutlet AccelerometerViewController *currentVC;
@property(nonatomic, retain) HighpassFilter *filter;


@end

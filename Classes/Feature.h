//
//  Feature.h
//  Accelerometer
//
//  Created by rouge on 10/9/14.
//
//

#ifndef __Accelerometer__Feature__
#define __Accelerometer__Feature__

#import <CoreMotion/CoreMotion.h>
#import "MotionFilter.h"

#include <stdio.h>
#include <vector>

using namespace std;

#endif /* defined(__Accelerometer__Feature__) */

#ifdef __cplusplus


class Feature
{
    
public:
    static vector<vector<float> > to2Dvector(NSMutableArray *plots);
    static vector<vector<float> > derivative(vector<vector<float> > input);
    static vector<vector<float> > highpassFilter(NSMutableArray *plots);
    static vector<float> getTotalFeature(vector<vector<float> > input);
    static vector<float> getPeakFeature(vector<vector<float> > input);
    static int getNumberOverThresh(vector<float> input, float max);


} ;

#endif
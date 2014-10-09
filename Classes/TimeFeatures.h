//
//  TimeFeatures.h
//  HackOnData
//
//  Created by Minwei Gu on 10/8/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

// we have 6 dimension (accX,accY,accZ,rotX,rotY,rorZ)
// feature list for each dimension:
// 1. zero crossing rate
// 2. root square mean
// 3. max envelope
// 4. skewness
// 5. curtosis
// 6. jerk
#ifndef __HackOnData__TimeFeatures__
#define __HackOnData__TimeFeatures__

#include <iostream>
#include <vector>
#include <math.h>
#include <string>

using namespace std;

class TimeFeatures
{
public:
  TimeFeatures();
  ~TimeFeatures();
  vector<double> getFeatures(vector<vector<double> > data);
  void featZcr(vector<double>& data);
  void featEnv(vector<double>& data);
  void featRms(vector<double>& data);
  void featSkewAndKurt(vector<double>& data);
  void featJerk(vector<double>& data);
  void normalization(vector<double>& data); 
  double getMax(vector<double>& data, int start = 0, int end = 0);
  double getMin(vector<double>& data, int start = 0, int end = 0);
  double getSum(vector<double>& data);
private:
  const int sampleRate = 100;
  const int blockSize = 32;
  const int hopSize = 16;
  vector<double> oneDimensionData;
  vector<double> featList;
};
#endif /* defined(__HackOnData__TimeFeatures__) */

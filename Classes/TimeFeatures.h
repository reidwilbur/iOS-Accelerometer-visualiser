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
  vector<float> getFeatures(vector<vector<float> > data);
  void featZcr(vector<float>& data);
  void featEnv(vector<float>& data);
  void featRms(vector<float>& data);
  void featSkewAndKurt(vector<float>& data);
  void featJerk(vector<float>& data);
  void normalization(vector<float>& data); 
  float getMax(vector<float>& data, int start = 0, int end = 0);
  float getMin(vector<float>& data, int start = 0, int end = 0);
  float getSum(vector<float>& data);
private:
  const int sampleRate = 100;
  const int blockSize = 32;
  const int hopSize = 16;
  vector<float> oneDimensionData;
  vector<float> featList;
};
#endif /* defined(__HackOnData__TimeFeatures__) */

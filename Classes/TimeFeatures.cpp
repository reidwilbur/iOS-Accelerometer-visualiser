//
//  TimeFeatures.cpp
//  HackOnData
//
//  Created by Minwei Gu on 10/8/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#include "TimeFeatures.h"

TimeFeatures::TimeFeatures(){
  
}

TimeFeatures::~TimeFeatures(){
  
}

vector<double> TimeFeatures::getFeatures(vector<vector<double> > data)
{
  featList.clear();
  for (int i = 0; i<data.size(); i++)   // calculate the features per dimension
  {
    oneDimensionData=data[i];
    normalization(oneDimensionData);
    featZcr(oneDimensionData);
    featRms(oneDimensionData);
    featEnv(oneDimensionData);
    featSkewAndKurt(oneDimensionData);
    featJerk(oneDimensionData);
  }
  return featList;
}

void TimeFeatures::normalization(vector<double>& data)
{
  double ref=getMax(data);
  for (int i = 0; i<data.size(); i++)
    data[i] = data[i]/ref;
}

void TimeFeatures::featZcr(vector<double>& data)
{
  // since this is the first feature we calculate, we clear the featlist
  size_t numSamples = data.size();
  vector<double> ZCRList;
  for (size_t i = 0; i<numSamples; i=i+hopSize)
  {
    if (i+blockSize-1>=numSamples)
      break;
    else
    {
      vector<double>::const_iterator first = data.begin()+i;
      vector<double>::const_iterator last = data.begin()+i+blockSize;
      vector<double> temp(first,last);
      int zcrCount = 0;
      for (int j =1; j<blockSize; j++)
      {
        if (temp[j]*temp[j-1]<0)
          zcrCount+=1;
      }
      ZCRList.push_back((double)zcrCount/blockSize);
    }
  }
  double meanZCR = getSum(ZCRList)/ZCRList.size();
  double sq_sum = 0.0;
  for (int j = 0; j<ZCRList.size(); j++)
    sq_sum+=(ZCRList[j]-meanZCR)*(ZCRList[j]-meanZCR);
  double stdevZCR = sqrt(sq_sum/(float)(ZCRList.size()-1));
  featList.push_back(meanZCR);
  featList.push_back(stdevZCR);
}

void TimeFeatures::featRms(vector<double>& data)
{
  size_t numSamples = data.size();
  vector <double> rmsList;
  for (size_t i = 0; i<numSamples; i = i+hopSize)
  {
    if (i+blockSize-1>=numSamples)
      break;
    else
    {
      float sum = 0;
      vector<double>::const_iterator first = data.begin()+i;
      vector<double>::const_iterator last = data.begin()+i+blockSize;
      vector<double> temp(first,last);
      for (int j = 0; j<blockSize; j++)
      {
        sum = sum + temp[j]*temp[j];
      }
      rmsList.push_back(sqrt(sum/blockSize));
    }
  }
  double meanRms = getSum(rmsList)/rmsList.size();
  double sq_sum = 0.0;
  for (int j = 0; j<rmsList.size(); j++)
    sq_sum+=(rmsList[j]-meanRms)*(rmsList[j]-meanRms);
  double stdevRms = sqrt(sq_sum/(float)(rmsList.size()-1));
  featList.push_back(meanRms);
  featList.push_back(stdevRms);
}

void TimeFeatures::featEnv(vector<double>& data)
{
  size_t numSamples = data.size();
  vector<double> envList;
  for (size_t i = 0 ; i<numSamples; i=i+hopSize)
  {
    if (i+blockSize-1>=numSamples)
      break;
    else
    {
      vector<double>::const_iterator first = data.begin()+i;
      vector<double>::const_iterator last = data.begin()+i+blockSize;
      vector<double> temp(first,last);
      float tempMaxEnv = getMax(temp);
      envList.push_back(tempMaxEnv);
    }
  }
  double meanEnv = getSum(envList)/envList.size();
  double sq_sum = 0.0;
  for (int j = 0; j<envList.size(); j++)
    sq_sum+=(envList[j]-meanEnv)*(envList[j]-meanEnv);
  float stdevEnv = sqrt(sq_sum/(float)(envList.size()-1));
  featList.push_back(meanEnv);
  featList.push_back(stdevEnv);
}

void TimeFeatures::featJerk(vector<double>& data)
{
  
}

void TimeFeatures :: featSkewAndKurt(vector<double>& data)
{
  size_t numSamples = data.size();
  double sum = getSum(data);
  double mean = sum / numSamples;
  
  float sq_sum = 0;
  for (size_t i=0; i<numSamples; i++)
    sq_sum += (data[i] - mean)*(data[i] - mean);
  double stdev = sqrt(sq_sum / (data.size()-1));
  
  double skewness = 0;
  for (size_t i = 0; i < numSamples; i++)
    skewness += (data[i] - mean)*(data[i] - mean)*(data[i] - mean);
  skewness = skewness/(numSamples * stdev * stdev * stdev);
  
  float kurtosis = 0;
  for (size_t i = 0; i < numSamples; i++)
    kurtosis += (data[i] - mean)*(data[i] - mean)*(data[i] - mean)*(data[i] - mean);
  kurtosis = kurtosis/(numSamples*stdev*stdev*stdev*stdev);
  featList.push_back(skewness);
  featList.push_back(kurtosis);
}

double TimeFeatures::getSum(vector<double>& tempData)
{
  float sum = 0;
  for (int i=0; i<tempData.size(); i++)
    sum += tempData[i];
  return sum;
}

double TimeFeatures::getMax(vector<double>& tempData, int start, int end)
{
  double max = 0;
  if (start >= end)
  {
    for (int i=0; i<tempData.size(); i++)
    {
      if (tempData[i]>max)
        max = tempData[i];
    }
  }
  else
  {
    for (int i=start; i<end; i++)
    {
      if (tempData[i]>max)
        max = tempData[i];
    }
  }
  return max;
}

double TimeFeatures::getMin(vector<double>& tempData, int start, int end)
{
  double min = 10000;
  if (start>=end)
  {
    for (int i=0; i<tempData.size(); i++)
    {
      if (tempData[i]<min)
        min = tempData[i];
    }
  }
  else
  {
    for (int i=start; i<end; i++)
    {
      if (tempData[i]<min)
        min = tempData[i];
    }
    
  }
  return min;
}
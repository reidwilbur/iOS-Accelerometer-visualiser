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

vector<float> TimeFeatures::getFeatures(vector<vector<float> > data)
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
    featAutoCorr(oneDimensionData);
  }
  return featList;
}

void TimeFeatures::normalization(vector<float>& data)
{
  float ref=getMax(data);
  for (int i = 0; i<data.size(); i++)
    data[i] = data[i]/ref;
}

void TimeFeatures::featZcr(vector<float>& data)
{
  // since this is the first feature we calculate, we clear the featlist
  size_t numSamples = data.size();
  vector<float> ZCRList;
  for (size_t i = 0; i<numSamples; i=i+hopSize)
  {
    if (i+blockSize-1>=numSamples)
      break;
    else
    {
      vector<float>::const_iterator first = data.begin()+i;
      vector<float>::const_iterator last = data.begin()+i+blockSize;
      vector<float> temp(first,last);
      int zcrCount = 0;
      for (int j =1; j<blockSize; j++)
      {
        if (temp[j]*temp[j-1]<0)
          zcrCount+=1;
      }
      ZCRList.push_back((float)zcrCount/blockSize);
    }
  }
  float meanZCR = getSum(ZCRList)/ZCRList.size();
  float sq_sum = 0.0;
  for (int j = 0; j<ZCRList.size(); j++)
    sq_sum+=(ZCRList[j]-meanZCR)*(ZCRList[j]-meanZCR);
  float stdevZCR = sqrt(sq_sum/(float)(ZCRList.size()-1));
  featList.push_back(meanZCR);
  //featList.push_back(stdevZCR);
}

void TimeFeatures::featRms(vector<float>& data)
{
  size_t numSamples = data.size();
  vector <float> rmsList;
  for (size_t i = 0; i<numSamples; i = i+hopSize)
  {
    if (i+blockSize-1>=numSamples)
      break;
    else
    {
      float sum = 0;
      vector<float>::const_iterator first = data.begin()+i;
      vector<float>::const_iterator last = data.begin()+i+blockSize;
      vector<float> temp(first,last);
      for (int j = 0; j<blockSize; j++)
      {
        sum = sum + temp[j]*temp[j];
      }
      rmsList.push_back(sqrt(sum/blockSize));
    }
  }
  float meanRms = getSum(rmsList)/rmsList.size();
  float sq_sum = 0.0;
  for (int j = 0; j<rmsList.size(); j++)
    sq_sum+=(rmsList[j]-meanRms)*(rmsList[j]-meanRms);
  float stdevRms = sqrt(sq_sum/(float)(rmsList.size()-1));
  featList.push_back(meanRms);
  //featList.push_back(stdevRms);
}

void TimeFeatures::featEnv(vector<float>& data)
{
  size_t numSamples = data.size();
  vector<float> envList;
  for (size_t i = 0 ; i<numSamples; i=i+hopSize)
  {
    if (i+blockSize-1>=numSamples)
      break;
    else
    {
      vector<float>::const_iterator first = data.begin()+i;
      vector<float>::const_iterator last = data.begin()+i+blockSize;
      vector<float> temp(first,last);
      float tempMaxEnv = getMax(temp);
      envList.push_back(tempMaxEnv);
    }
  }
  float meanEnv = getSum(envList)/envList.size();
  float sq_sum = 0.0;
  for (int j = 0; j<envList.size(); j++)
    sq_sum+=(envList[j]-meanEnv)*(envList[j]-meanEnv);
  float stdevEnv = sqrt(sq_sum/(float)(envList.size()-1));
  featList.push_back(meanEnv);
  //featList.push_back(stdevEnv);
}

void TimeFeatures::featAutoCorr(vector<float> &data)
{
  size_t numSamples = data.size();
  vector<float> corrList;
  for (size_t i=0; i<numSamples; i=i+hopSize)
  {
    if(i+blockSize-1>=numSamples)
      break;
    else
    {
      float tempCorr = 0;
      float tempVar = 0;
      vector<float>::const_iterator first = data.begin()+i;
      vector<float>::const_iterator last = data.begin()+i+blockSize;
      vector<float> temp(first,last);
      float tempMean = getSum(temp)/temp.size();
      for (int j = 0; j<temp.size(); j++)
      {
        float oneVar = (temp[j]-tempMean) * (temp[j]-tempMean);
        tempVar+=oneVar;
      }
      for (int j = 0; j<temp.size(); j++)
      {
        //tempCorr+=(temp[j]-tempMean)*(temp[j]-tempMean)/tempVar;
        tempCorr+=temp[j]*temp[j]/tempVar;
      }
      corrList.push_back(tempCorr);
    }
  }
  float meanCorr = getSum(corrList)/corrList.size();
  featList.push_back(meanCorr);
}

void TimeFeatures :: featSkewAndKurt(vector<float>& data)
{
  size_t numSamples = data.size();
  float sum = getSum(data);
  float mean = sum / numSamples;
  
  float sq_sum = 0;
  for (size_t i=0; i<numSamples; i++)
    sq_sum += (data[i] - mean)*(data[i] - mean);
  float stdev = sqrt(sq_sum / (data.size()-1));
  
  float skewness = 0;
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

float TimeFeatures::getSum(vector<float>& tempData)
{
  float sum = 0;
  for (int i=0; i<tempData.size(); i++)
    sum += tempData[i];
  return sum;
}

float TimeFeatures::getMax(vector<float>& tempData, int start, int end)
{
  float max = 0;
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

float TimeFeatures::getMin(vector<float>& tempData, int start, int end)
{
  float min = 10000;
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
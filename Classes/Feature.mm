//
//  Feature.cpp
//  Accelerometer
//
//  Created by rouge on 10/9/14.
//
//
#include "Feature.h"
#include "TimeFeatures.h"
using namespace std;


vector<vector<float> > Feature::to2Dvector(NSMutableArray *plots){
    vector<vector<float> > result;
    int size = (int)[plots count];
    vector<float> x(size);
    vector<float> y(size);
    vector<float> z(size);
    vector<float> rx(size);
    vector<float> ry(size);
    vector<float> rz(size);
    
    for (int i=1; i<[plots count]; i++) {
        CMDeviceMotion *a = [plots objectAtIndex:i];
        x.at(i)=(a.userAcceleration.x);
        y.at(i)=(a.userAcceleration.y);
        z.at(i)=(a.userAcceleration.z);
        rx.at(i)=(a.rotationRate.x);
        ry.at(i)=(a.rotationRate.y);
        rz.at(i)=(a.rotationRate.z);
    }
    result.push_back(x);
    result.push_back(y);
    result.push_back(z);
    result.push_back(rx);
    result.push_back(ry);
    result.push_back(rz);
    return result;
}


vector<vector<float> > Feature::derivative(vector<vector<float> > input){
    vector<vector<float> > result;
    
    for(int i = 0; i<input.size(); ++i){
        vector<float> d (input[i].size(),0.0);
        for(int j = 0; j<input[i].size()-1; ++j){
            d.at(j) = input[i][j+1]-input[i][j];
        }
        result.push_back(d);
    }
    return result;
}

vector<vector<float> > Feature::highpassFilter(NSMutableArray *plots){
    HighpassFilter *filter = [[HighpassFilter alloc] initWithSampleRate:60 cutoffFrequency:5.0];
    vector<vector<float> > result;
    int size = (int)[plots count];
    vector<float> x(size);
    vector<float> y(size);
    vector<float> z(size);
    vector<float> rx(size);
    vector<float> ry(size);
    vector<float> rz(size);
    
    for (int i=1; i<[plots count]; i++) {
        CMDeviceMotion *a = [plots objectAtIndex:i];
        [filter addMotion:a];
        x.at(i)=(filter.x);
        y.at(i)=(filter.y);
        z.at(i)=(filter.z);
        rx.at(i)=(filter.rx);
        ry.at(i)=(filter.ry);
        rz.at(i)=(filter.rz);
    }
    result.push_back(x);
    result.push_back(y);
    result.push_back(z);
    result.push_back(rx);
    result.push_back(ry);
    result.push_back(rz);
    return result;
}


vector<float> Feature::getPeakFeature(vector<vector<float> > input){
    vector<float> result;
    float maxX = *max_element(input[0].begin(), input[0].end());
    float maxY = *max_element(input[1].begin(), input[1].end());
    float maxZ = *max_element(input[2].begin(), input[2].end());
    float maxA = fmaxf(fmaxf(maxX, maxY),maxZ);
    
    float maxRX = *max_element(input[3].begin(), input[3].end());
    float maxRY = *max_element(input[4].begin(), input[4].end());
    float maxRZ = *max_element(input[5].begin(), input[5].end());
    float maxR = fmaxf(fmaxf(maxRX, maxRY),maxRZ);

    result.push_back(getNumberOverThresh(input[0],maxA));
    result.push_back(getNumberOverThresh(input[1],maxA));
    result.push_back(getNumberOverThresh(input[2],maxA));
    result.push_back(getNumberOverThresh(input[0],maxX));
    result.push_back(getNumberOverThresh(input[1],maxY));
    result.push_back(getNumberOverThresh(input[2],maxZ));

    result.push_back(getNumberOverThresh(input[3],maxR));
    result.push_back(getNumberOverThresh(input[4],maxR));
    result.push_back(getNumberOverThresh(input[5],maxR));
    result.push_back(getNumberOverThresh(input[3],maxRX));
    result.push_back(getNumberOverThresh(input[4],maxRY));
    result.push_back(getNumberOverThresh(input[5],maxRZ));
    return result;
}


int Feature::getNumberOverThresh(vector<float> input, float max){
    int count = 0;
    float thresh = max/4;
    for (std::vector<float>::iterator it = input.begin() ; it != input.end(); ++it){
        if(*it>thresh)
            ++count;
    }
    return count;
}

vector<float> Feature::getTotalFeature(vector<vector<float> > input){
    vector<vector<float> > firstD = Feature::derivative(input);
    vector<vector<float> > secondD = Feature::derivative(firstD);
    vector<vector<float> > thirdD = Feature::derivative(secondD);
    vector<vector<float> > fourthD = Feature::derivative(thirdD);
    vector<float> a = getPeakFeature(thirdD);
    vector<float> b = getPeakFeature(fourthD);
    a.insert( a.end(), b.begin(), b.end() );
//    vector<float> a;
    TimeFeatures timeFeatures;
    vector<float> timeFeatList = timeFeatures.getFeatures(fourthD);
    a.insert(a.end(),timeFeatList.begin(), timeFeatList.end());
    return a;
}



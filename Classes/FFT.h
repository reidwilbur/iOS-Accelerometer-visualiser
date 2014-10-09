//
//  FFT.h
//  Accelerometer
//
//  Created by rouge on 10/7/14.
//
//

#ifdef __cplusplus

#include <Accelerate/Accelerate.h>

class FFT
{
    
public:
    FFT(int numSamples);
    ~FFT();
    void doFFTReal(float samples[], float amp[], int numSamples);
    
private:
    FFTSetup fftSetup;
    COMPLEX_SPLIT A;
} ;

#endif
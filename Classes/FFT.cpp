#include "FFT.h"
#include <stdio.h>
#include <stdlib.h>
#include <Accelerate/Accelerate.h>
#include <math.h>

void FFT::doFFTReal(float samples[], float amp[], int numSamples)
{
    vDSP_Length log2n = log2f(numSamples);
    
    //Convert float array of reals samples to COMPLEX_SPLIT array A
    vDSP_ctoz((COMPLEX*)samples,2,&A,1,numSamples/2);
    
    //Perform FFT using fftSetup and A
    //Results are returned in A
    vDSP_fft_zrip(fftSetup, &A, 1, log2n, FFT_FORWARD);
    
    //Convert COMPLEX_SPLIT A result to float array to be returned
    
    vDSP_zvmags(&A, 1, amp, 1, numSamples); // get amplitude squared
    vvsqrtf(amp, amp, &numSamples);         // get amplitude
    amp[0] = amp[0]/2.;
    
    float fNumSamples = numSamples;
    vDSP_vsdiv(amp, 1, &fNumSamples, amp, 1, numSamples);   // /numSamples
}

//Constructor
FFT::FFT (int numSamples)
{
    vDSP_Length log2n = log2f(numSamples);
    fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    int nOver2 = numSamples/2;
    A.realp = (float *) malloc(nOver2*sizeof(float));
    A.imagp = (float *) malloc(nOver2*sizeof(float));
}


//Destructor
FFT::~FFT ()
{
    free(A.realp);
    free(A.imagp);
    vDSP_destroy_fftsetup(fftSetup);
}


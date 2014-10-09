#import "MotionFilter.h"

// Implementation of the basic filter. All it does is mirror input to output.

@implementation MotionFilter

@synthesize x, y, z, rx, ry, rz, adaptive;

- (void)addMotion:(CMDeviceMotion *)motion
{
    x = motion.userAcceleration.x;
    y = motion.userAcceleration.y;
    z = motion.userAcceleration.z;
    
    rx = motion.rotationRate.x;
    ry = motion.rotationRate.y;
    rz = motion.rotationRate.z;
}

- (NSString *)name
{
    return @"You should not see this";
}

@end


#pragma mark -

#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0

double Norm(double x, double y, double z)
{
    return sqrt(x * x + y * y + z * z);
}

double Clamp(double v, double min, double max)
{
    if(v > max)
        return max;
    else if(v < min)
        return min;
    else
        return v;
}


#pragma mark -

// See http://en.wikipedia.org/wiki/Low-pass_filter for details low pass filtering
@implementation LowpassFilter

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
    self = [super init];
    if(self != nil)
    {
        double dt = 1.0 / rate;
        double RC = 1.0 / freq;
        filterConstant = dt / (dt + RC);
        adaptive = YES;
    }
    return self;
}

- (void)addMotion:(CMDeviceMotion *)motion
{
    double alpha = filterConstant;
    double ralpha = filterConstant;

    
    if(adaptive)
    {
        double d = Clamp(fabs(Norm(x, y, z) - Norm(motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
        alpha = (1.0 - d) * filterConstant / kAccelerometerNoiseAttenuation + d * filterConstant;
        
       
        double rd = Clamp(fabs(Norm(x, y, z) - Norm(motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
        ralpha = (1.0 - rd) * filterConstant / kAccelerometerNoiseAttenuation + rd * filterConstant;
    }
    
    x = motion.userAcceleration.x * alpha + x * (1.0 - alpha);
    y = motion.userAcceleration.y * alpha + y * (1.0 - alpha);
    z = motion.userAcceleration.z * alpha + z * (1.0 - alpha);
    
    rx = motion.rotationRate.x * ralpha + rx * (1.0 - ralpha);
    ry = motion.rotationRate.y * ralpha + ry * (1.0 - ralpha);
    rz = motion.rotationRate.z * ralpha + rz * (1.0 - ralpha);
}

- (NSString *)name
{
    return adaptive ? @"Adaptive Lowpass Filter" : @"Lowpass Filter";
}

@end


#pragma mark -

// See http://en.wikipedia.org/wiki/High-pass_filter for details on high pass filtering
@implementation HighpassFilter

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
    self = [super init];
    if (self != nil)
    {
        double dt = 1.0 / rate;
        double RC = 1.0 / freq;
        filterConstant = RC / (dt + RC);
        adaptive = YES;
    }
    return self;
}


- (void)addMotion:(CMDeviceMotion *)motion
{
    double alpha = filterConstant;
    double ralpha = filterConstant;
    
    if (adaptive){
        double d = Clamp(fabs(Norm(x, y, z) - Norm(motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
        alpha = d * filterConstant / kAccelerometerNoiseAttenuation + (1.0 - d) * filterConstant;
        
        double rd = Clamp(fabs(Norm(rx, ry, rz) - Norm(motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
        ralpha = rd * filterConstant / kAccelerometerNoiseAttenuation + (1.0 - rd) * filterConstant;
    }
    
    x = alpha * (x + motion.userAcceleration.x - lastX);
    y = alpha * (y + motion.userAcceleration.y - lastY);
    z = alpha * (z + motion.userAcceleration.z - lastZ);
    
    lastX = motion.userAcceleration.x;
    lastY = motion.userAcceleration.y;
    lastZ = motion.userAcceleration.z;
    
    
    
    rx = ralpha * (rx + motion.rotationRate.x - lastRX);
    ry = ralpha * (ry + motion.rotationRate.y - lastRY);
    rz = ralpha * (rz + motion.rotationRate.z - lastRZ);
    
    lastRX = motion.rotationRate.x;
    lastRY = motion.rotationRate.y;
    lastRZ = motion.rotationRate.z;
}

- (NSString *)name
{
    return adaptive ? @"Adaptive Highpass Filter" : @"Highpass Filter";
}

@end
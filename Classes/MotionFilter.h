#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


// Basic filter object.
@interface MotionFilter : NSObject
{
    BOOL adaptive;
    double x, y, z, rx, ry, rz;
}

// Add a UIAcceleration to the filter.
- (void)addMotion:(CMDeviceMotion*)motion;

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double z;

@property (nonatomic, readonly) double rx;
@property (nonatomic, readonly) double ry;
@property (nonatomic, readonly) double rz;

@property (nonatomic, getter=isAdaptive) BOOL adaptive;
@property (unsafe_unretained, nonatomic, readonly) NSString *name;

@end

#pragma mark -

// A filter class to represent a lowpass filter
@interface LowpassFilter : MotionFilter
{
    double filterConstant;
    double lastX, lastY, lastZ;
    double lastRX, lastRY, lastRZ;
}

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

@end

#pragma mark -

// A filter class to represent a highpass filter.
@interface HighpassFilter : MotionFilter
{
    double filterConstant;
    double lastX, lastY, lastZ;
    double lastRX, lastRY, lastRZ;
}

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

@end
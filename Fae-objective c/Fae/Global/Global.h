#import <UIKit/UIKit.h>

#import "FaeAppDelegate.h"

typedef enum {
    DEVICE_IPHONE_35INCH,
    DEVICE_IPHONE_40INCH,
    DEVICE_IPHONE_47INCH,
    DEVICE_IPHONE_55INCH,
    DEVICE_IPAD,
} DEVICE_TYPE;

typedef enum {
    IOS_8 = 4,
    IOS_7 = 3,
    IOS_6 = 2,
    IOS_5 = 1,
    IOS_4 = 0,
} IOS_VERSION;

typedef enum{
    
    FAE_SEX_NONE,
    FAE_SEX_MALE,
    FAE_SEX_FEMALE,
    
} FAE_SEX;

IOS_VERSION gIOSVersion;

DEVICE_TYPE gDeviceType;
CGSize  gScreenSize;
CGFloat gScaleFactor;

UIInterfaceOrientation gDeviceOrientation;

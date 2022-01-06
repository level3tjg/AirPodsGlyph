#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaRemote/MediaRemote.h>

@interface AVOutputDevice : NSObject
@end

@interface AVOutputContext : NSObject
- (AVOutputDevice *)outputDevice;
@end

@interface FBSystemService
+ (id)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg1;
@end

@interface MRAVOutputDevice : NSObject
@end

@interface MRAVOutputDeviceSourceInfo : NSObject
@end

@interface MRAVConcreteOutputDevice : MRAVOutputDevice
- (instancetype)initWithAVOutputDevice:(AVOutputDevice *)avOutputDevice
                            sourceInfo:(MRAVOutputDeviceSourceInfo *)sourceInfo;
@end

@interface MPAVRoute : NSObject
@property NSInteger routeSubtype;
@property(getter=isHeadphonesRoute) BOOL headphonesRoute;
@property(getter=isClusterRoute) BOOL clusterRoute;
@property(getter=isAirpodsRoute) BOOL airpodsRoute;
@property(getter=isB298Route) BOOL b298Route;
@property(getter=isB515Route) BOOL b515Route;
@property(getter=isB688Route) BOOL b688Route;
@end

@interface MPAVOutputDeviceRoute : MPAVRoute
- (instancetype)initWithOutputDevices:(NSArray<MRAVConcreteOutputDevice *> *)outputDevices;
+ (instancetype)systemAudioRoute;
@end

@interface MRAVOutputContext : NSObject
@property AVOutputContext *avOutputContext;
+ (instancetype)sharedSystemAudioContext;
@end

@interface UIImage ()
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end
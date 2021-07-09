#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaRemote/MediaRemote.h>
#import <MediaPlayer/MediaPlayer.h>

#define PREFS_PATH @"/var/mobile/Library/Preferences/com.level3tjg.airpodsglyph.plist"

@interface AVOutputDevice : NSObject
@end

@interface MRAVOutputDevice : NSObject
@end

@interface MRAVOutputDeviceSourceInfo : NSObject
@end

@interface MRAVConcreteOutputDevice : MRAVOutputDevice
- (instancetype)initWithAVOutputDevice:(AVOutputDevice *)avOutputDevice sourceInfo:(MRAVOutputDeviceSourceInfo *)sourceInfo;
@end

@interface MPAVRoute : NSObject
@property (getter=isAirpodsRoute) BOOL airpodsRoute;
@property (getter=isB298Route) BOOL b298Route;
@property (getter=isB515Route) BOOL b515Route;
@end

@interface MPAVOutputDeviceRoute : MPAVRoute
- (instancetype)initWithOutputDevices:(NSArray <MRAVConcreteOutputDevice *>*)outputDevices;
+ (instancetype)systemAudioRoute;
@end

@interface AVOutputContext : NSObject
- (AVOutputDevice *)outputDevice;
@end

@interface MRAVOutputContext : NSObject
@property AVOutputContext *avOutputContext;
+ (instancetype)sharedSystemAudioContext;
@end

@interface UIImage (Private)
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

BOOL airpodsMaxConnected() {
	MPAVOutputDeviceRoute *route = [MPAVOutputDeviceRoute systemAudioRoute];
	return [route respondsToSelector:@selector(isB515Route)] && ([[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH][@"forceAirpodsMax"] boolValue] ||  route.b515Route);
}

BOOL airpodsProConnected() {
	MPAVOutputDeviceRoute *route = [MPAVOutputDeviceRoute systemAudioRoute];
	return [route respondsToSelector:@selector(isB298Route)] && ([[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH][@"forceAirpodsPro"] boolValue] || route.b298Route);
}

BOOL airpodsConnected() {
	MPAVOutputDeviceRoute *route = [MPAVOutputDeviceRoute systemAudioRoute];
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
	return ([prefs[@"forceAirpods"] boolValue] || [prefs[@"forceAirpodsPro"] boolValue] || [prefs[@"forceAirpodsMax"] boolValue]) || (route.airpodsRoute || airpodsMaxConnected());
}

UIImage *airpodsImage() {
	NSBundle *batteryCenterBundle = [NSBundle bundleWithIdentifier:@"com.apple.BatteryCenterUI"];
	if (!batteryCenterBundle)
		batteryCenterBundle = [NSBundle bundleWithIdentifier:@"com.apple.BatteryCenter"];
	UIImage *image;
	if (airpodsMaxConnected()) {
		image = [UIImage imageNamed:@"batteryglyphs-b515" inBundle:batteryCenterBundle];
	} else if (airpodsProConnected()) {
		image = [UIImage imageNamed:@"batteryglyphs-airpodspro-left-right" inBundle:batteryCenterBundle];
		if (!image)
			image = [UIImage imageNamed:@"batteryglyphs-b298-left-right" inBundle:batteryCenterBundle];
	} else {
		image = [UIImage imageNamed:@"batteryglyphs-airpods-left-right" inBundle:batteryCenterBundle];
	}
	return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

%hook MPAVOutputDeviceRoute
%new
+ (instancetype)systemAudioRoute {
	MRAVOutputContext *context = [MRAVOutputContext sharedSystemAudioContext];
	AVOutputDevice *avOutputDevice = [context.avOutputContext outputDevice];
	MRAVConcreteOutputDevice *outputDevice = [[MRAVConcreteOutputDevice alloc] initWithAVOutputDevice:avOutputDevice sourceInfo:[context valueForKey:@"_outputDeviceSourceInfo"]];
	MPAVOutputDeviceRoute *route = [[MPAVOutputDeviceRoute alloc] initWithOutputDevices:@[ outputDevice ]];
	return route;
}
%end

%hook _UIStatusBarBluetoothItem
- (UIImage *)imageForUpdate:(id)update {
	if (airpodsConnected())
		return airpodsImage();
	return %orig;
}
%end

%hook MediaControlsVolumeController
- (NSString *)_packageNameForRoute:(MPAVOutputDeviceRoute *)route isRTL:(BOOL)rtl isSlider:(BOOL)slider {
	if (([%orig hasSuffix:@"GenericBluetooth"] || [%orig hasSuffix:@"AirPods"] || [%orig hasSuffix:@"B298"] || [%orig hasSuffix:@"B515"]) && airpodsConnected()) {
		if (airpodsMaxConnected())
			return @"Volume-B515";
		else if (airpodsProConnected())
			return @"Volume-B298";
		else
			return @"VolumeAirPods";
	}
	return %orig;
}
%end

static void respring(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object,  CFDictionaryRef userInfo) {
  [[%c(FBSystemService) performSelector:@selector(sharedInstance)] performSelector:@selector(exitAndRelaunch:) withObject:@NO];
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respring, CFSTR("respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
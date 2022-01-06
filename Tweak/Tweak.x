#import "Tweak.h"

static NSDictionary *prefs;

%hook MPAVRoute
%new
- (BOOL)isHeadphonesRoute {
  return self.routeSubtype - 2 > 11;
}
- (BOOL)isAirpodsRoute {
  return (self.headphonesRoute && [prefs[@"forceAirpods"] boolValue]) ||
         %orig;
}
- (BOOL)isB298Route {
  return (self.headphonesRoute && [prefs[@"forceAirpodsPro"] boolValue]) ||
         %orig;
}
- (BOOL)isB515Route {
  return (self.headphonesRoute && [prefs[@"forceAirpodsMax"] boolValue]) ||
         %orig;
}
- (BOOL)isB688Route {
  return (self.headphonesRoute && [prefs[@"forceAirpodsGen3"] boolValue]) ||
         %orig;
}
%end

%hook MPAVOutputDeviceRoute
%new
+ (instancetype)systemAudioRoute {
  MRAVOutputContext *context = [MRAVOutputContext sharedSystemAudioContext];
  if (!context || !context.avOutputContext)
    return nil;
  AVOutputDevice *avOutputDevice = [context.avOutputContext outputDevice];
  if (!avOutputDevice)
    return nil;
  MRAVConcreteOutputDevice *outputDevice = [[MRAVConcreteOutputDevice alloc]
      initWithAVOutputDevice:avOutputDevice
                  sourceInfo:[context valueForKey:@"_outputDeviceSourceInfo"]];
  MPAVOutputDeviceRoute *route =
      [[MPAVOutputDeviceRoute alloc] initWithOutputDevices:@[ outputDevice ]];
  return route;
}
%end

%hook _UIStatusBarBluetoothItem
- (UIImage *)imageForUpdate:(id)update {
  UIImage *image;
  MPAVRoute *route = [MPAVOutputDeviceRoute systemAudioRoute];
  NSBundle *batteryCenterBundle =
      [NSBundle bundleWithIdentifier:@"com.apple.BatteryCenterUI"];
  if (!batteryCenterBundle)
    batteryCenterBundle =
        [NSBundle bundleWithIdentifier:@"com.apple.BatteryCenter"];
  if ([route respondsToSelector:@selector(isB688Route)] && route.b688Route) {
    image = [UIImage imageNamed:@"B688" inBundle:batteryCenterBundle];
    if (!image)
      image = [UIImage systemImageNamed:@"airpods.gen3"];
  } else if ([route respondsToSelector:@selector(isB515Route)] &&
             route.b515Route) {
    image = [UIImage imageNamed:@"batteryglyphs-b515"
                       inBundle:batteryCenterBundle];
    if (!image)
      image = [UIImage systemImageNamed:@"airpodsmax"];
  } else if ([route respondsToSelector:@selector(isB298Route)] &&
             route.b298Route) {
    image = [UIImage imageNamed:@"batteryglyphs-b298-left-right"
                       inBundle:batteryCenterBundle];
    if (!image)
      image = [UIImage imageNamed:@"batteryglyphs-airpodspro-left-right"
                         inBundle:batteryCenterBundle];
    if (!image)
      image = [UIImage systemImageNamed:@"airpodspro"];
  } else if ([route respondsToSelector:@selector(isAirpodsRoute)] &&
             route.airpodsRoute) {
    image = [UIImage imageNamed:@"batteryglyphs-airpods-left-right"
                       inBundle:batteryCenterBundle];
    if (!image)
      image = [UIImage systemImageNamed:@"airpods"];
  }
  if (!image)
    return %orig;
  return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
%end

%hook MediaControlsVolumeViewController
- (void)viewDidLoad {
  %orig;
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(_updateGlyphPackageDescription)
             name:@"com.level3tjg.airpodsglyph/prefsChanged"
           object:nil];
}
%end

static void prefsChanged(CFNotificationCenterRef center, void *observer,
                         CFStringRef name, const void *object,
                         CFDictionaryRef userInfo) {
  prefs = [NSDictionary
      dictionaryWithContentsOfFile:
          @"/var/mobile/Library/Preferences/com.level3tjg.airpodsglyph.plist"];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:@"com.level3tjg.airpodsglyph/prefsChanged"
                    object:nil];
}

%ctor {
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), NULL,
      (CFNotificationCallback)prefsChanged,
      CFSTR("com.level3tjg.airpodsglyph/prefsChanged"), NULL,
      CFNotificationSuspensionBehaviorDeliverImmediately);
  prefsChanged(NULL, NULL, NULL, NULL, NULL);
}

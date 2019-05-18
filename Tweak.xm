#include <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface BluetoothDevice
-(bool)isAppleAudioDevice;
-(bool)magicPaired;
@end

@interface BluetoothManager
+(BluetoothManager *)sharedInstance;
-(NSArray *)connectedDevices;
@end

@interface UIStatusBarItem
-(NSString *)indicatorName;
@end

@interface UIStatusBarIndicatorItemView : UIView
@end

@interface _UILegibilityImageSet
-(void)setImage:(UIImage *)image;
@end

%hook _UIStatusBarBluetoothItem
-(UIImageView *)imageView{
	UIImageView *newView = %orig;
	bool airpodsConnected = false;
	for(BluetoothDevice *device in [[%c(BluetoothManager) sharedInstance] connectedDevices]){
		if([device isAppleAudioDevice] && [device magicPaired]){
			airpodsConnected = true;
		}
	}
	UIImage *airpodsImage;
	if(airpodsConnected){
		airpodsImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/AirPodsGlyph/whiteAirpods.png"];
		MSHookIvar<CGFloat>(airpodsImage, "_scale") = 4;
		[newView setImage:airpodsImage];
	}
	return newView;
}
%end

%hook UIStatusBarIndicatorItemView
-(_UILegibilityImageSet *)contentsImage{
	_UILegibilityImageSet *set = %orig;
	bool airpodsConnected = false;
	for(BluetoothDevice *device in [[%c(BluetoothManager) sharedInstance] connectedDevices]){
		if([device isAppleAudioDevice] && [device magicPaired]){
			airpodsConnected = true;
		}
	}
	UIImage *airpodsImage;
	if(([[MSHookIvar<UIStatusBarItem *>(self, "_item") indicatorName] isEqualToString:@"BTHeadphones"])/* && (airpodsConnected)*/){
		if([[UIApplication sharedApplication] statusBarStyle] == 0){
			airpodsImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/AirPodsGlyph/blackAirpods.png"];
		}
		else{
			airpodsImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/AirPodsGlyph/whiteAirpods.png"];
		}
		MSHookIvar<CGFloat>(airpodsImage, "_scale") = 4;
		[set setImage:airpodsImage];
	}
	return set;
}
%end
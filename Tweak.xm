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

bool airpodsConnected(){
	for(BluetoothDevice *device in [[%c(BluetoothManager) sharedInstance] connectedDevices]){
		if([device isAppleAudioDevice] && [device magicPaired]){
			return true;
		}
	}
	return false;
}

void setImageForObj(UIImageView *obj){
	UIImage *airpodsImage;
	if(airpodsConnected()){
		if([[UIApplication sharedApplication] statusBarStyle] == 0){
			airpodsImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/AirPodsGlyph/blackAirpods.png"];
		}
		else{
			airpodsImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/AirPodsGlyph/whiteAirpods.png"];
		}
		MSHookIvar<CGFloat>(airpodsImage, "_scale") = 4;
		[obj setImage:airpodsImage];

	}
}

%hook _UIStatusBarBluetoothItem
-(UIImageView *)imageView{
	UIImageView *newView = %orig;
	setImageForObj(newView);
	return newView;
}
%end

%hook UIStatusBarIndicatorItemView
-(_UILegibilityImageSet *)contentsImage{
	_UILegibilityImageSet *set = %orig;
	if(([[MSHookIvar<UIStatusBarItem *>(self, "_item") indicatorName] isEqualToString:@"BTHeadphones"]))
		setImageForObj((UIImageView *)set);
	return set;
}
%end
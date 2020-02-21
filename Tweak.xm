#import <objc/runtime.h>
#import <substrate.h>

@interface UIImageAsset (Private)
@property (nonatomic, assign) NSString *assetName;
@end

@interface _UIAssetManager
+(id)assetManagerForBundle:(NSBundle *)bundle;
-(UIImage *)imageNamed:(NSString *)name;
@end

@interface UIImage (Private)
@property (nonatomic, assign) CGSize pixelSize;
-(UIImage *)sbf_resizeImageToSize:(CGSize)size;
@end

@interface BCBatteryDeviceController
+(BCBatteryDeviceController *)sharedInstance;
-(NSArray *)connectedDevices;
@end

@interface BCBatteryDevice
@property (nonatomic, assign) UIImage *glyph;
@end

@interface UIStatusBarItem
@property (nonatomic, assign) NSString *indicatorName;
@property (nonatomic, assign) Class viewClass;
@end

@interface UIStatusBarItemView
@property (nonatomic, assign) UIStatusBarItem *item;
@end

@interface UIStatusBarIndicatorItemView : UIStatusBarItemView
@end

bool airpodsConnected(){
	for(BCBatteryDevice *device in [[objc_getClass("BCBatteryDeviceController") sharedInstance] connectedDevices]){
		if([device.glyph.imageAsset.assetName containsString:@"airpods"] || [device.glyph.imageAsset.assetName containsString:@"b298"])
			return true;
	}
	return false;
}

bool airpodsProConnected(){
	if(@available(iOS 13, *)){
		for(BCBatteryDevice *device in [[objc_getClass("BCBatteryDeviceController") sharedInstance] connectedDevices]){
			if([device.glyph.imageAsset.assetName containsString:@"b298"]){
				return true;
			}
		}
	}
	return false;
}

UIImage *airpodsImage(){
	UIImage *airpods;
	CGSize imgsize;
	airpods = [[objc_getClass("_UIAssetManager") assetManagerForBundle:[NSBundle bundleWithIdentifier:@"com.apple.BatteryCenter"]] imageNamed:@"batteryglyphs-airpods-left-right"];
	if(@available(iOS 13, *)){
		if(airpodsProConnected())
			airpods = [[objc_getClass("_UIAssetManager") assetManagerForBundle:[NSBundle bundleWithIdentifier:@"com.apple.BatteryCenter"]] imageNamed:@"batteryglyphs-b298-left-right"];
	}
	imgsize = CGSizeMake(airpods.size.width/2, airpods.size.height/2);
	if(@available(iOS 11, *)){
		if(!airpodsProConnected())
			imgsize = CGSizeMake(airpods.size.width/1.5, airpods.size.height/1.5);
	}
	return [[airpods sbf_resizeImageToSize:imgsize] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

void setImageForObj(UIImageView *obj){
	if(airpodsConnected())
		obj.image = airpodsImage();
}

%hook UIImage
-(UIImage *)_imageWithImageAsset:(UIImageAsset *)asset{
	if([asset.assetName isEqualToString:@"headphones"] && [MSHookIvar<NSBundle *>(asset, "_containingBundle").bundleIdentifier isEqualToString:@"com.apple.CoreGlyphs"])
		if(airpodsConnected())
			return airpodsImage();
	return %orig();
}
%end

%hook _UIStatusBarBluetoothItem
-(UIImageView *)imageView{
	UIImageView *imageView = %orig;
	setImageForObj(imageView);
	return imageView;
}
%end

%hook UIStatusBarIndicatorItemView
-(UIImageView *)contentsImage{
	UIImageView *imageView = %orig;
	if([self.item.indicatorName isEqualToString:@"BTHeadphones"] || [NSStringFromClass(self.item.viewClass) containsString:@"Bluetooth"])
		setImageForObj(imageView);
	return imageView;
}
-(BOOL)shouldTintContentImage{
	if([self.item.indicatorName isEqualToString:@"BTHeadphones"] || [NSStringFromClass(self.item.viewClass) containsString:@"Bluetooth"])
		return true;
	return %orig;
}
%end

%hook _UIStatusBarImageView
-(UIImage *)image{
	return [%orig imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
%end

%ctor{
	dlopen("/System/Library/PrivateFrameworks/BatteryCenter.framework/BatteryCenter", RTLD_LAZY);
}
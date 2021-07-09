TARGET := iphone:clang:latest:13.0

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AirPodsGlyphPrefs

AirPodsGlyphPrefs_FILES = APGRootListController.m
AirPodsGlyphPrefs_FRAMEWORKS = UIKit MediaPlayer
AirPodsGlyphPrefs_PRIVATE_FRAMEWORKS = Preferences
AirPodsGlyphPrefs_INSTALL_PATH = /Library/PreferenceBundles
AirPodsGlyphPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

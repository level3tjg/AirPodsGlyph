TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_DEVICE_IP = 10.12.3.128

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AirPodsGlyph

AirPodsGlyph_FILES = Tweak.x
AirPodsGlyph_CFLAGS = -fobjc-arc
AirPodsGlyph_FRAMEWORKS = UIKit MediaPlayer
AirPodsGlyph_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

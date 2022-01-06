export TARGET = iphone:clang:latest:13.0
export ARCHS = arm64 arm64e

THEOS_DEVICE_IP = 10.12.14.60

include $(THEOS)/makefiles/common.mk
SUBPROJECTS += Tweak
SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

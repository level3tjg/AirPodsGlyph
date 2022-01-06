export TARGET = iphone:clang:latest:13.0
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk
SUBPROJECTS += Tweak
SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

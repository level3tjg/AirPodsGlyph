THEOS_DEVICE_IP = 192.168.1.123

include $(THEOS)/makefiles/common.mk

ARCHS = armv7 arm64 arm64e

TWEAK_NAME = AirPodsGlyph
AirPodsGlyph_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

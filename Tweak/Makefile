INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_DEVICE_IP = 10.12.14.60

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AirPodsGlyph

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit MediaPlayer
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
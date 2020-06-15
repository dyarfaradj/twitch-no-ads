ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TWNAPref
TWNAPref_FILES = $(wildcard *.m)
TWNAPref_INSTALL_PATH = /Library/PreferenceBundles
TWNAPref_PRIVATE_FRAMEWORKS = Preferences
TWNAPref_EXTRA_FRAMEWORKS = libhdev
TWNAPref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TWNAPref.plist$(ECHO_END)

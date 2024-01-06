TARGET := iphone:clang:15.0
SYSROOT = $(THEOS)/sdks/iPhoneOS16.5.sdk
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TOOL_NAME = PicassoRootHelper

$(TOOL_NAME)_FILES = $(wildcard *.m)
$(TOOL_NAME)_CFLAGS = -fobjc-arc -O2
$(TOOL_NAME)_CODESIGN_FLAGS = -Sentitlements.plist
$(TOOL_NAME)_INSTALL_PATH = /usr/local/bin
$(TOOL_NAME)_PRIVATE_FRAMEWORKS = SpringBoardServices BackBoardServices MobileCoreServices MobileContainerManager CoreFoundation

include $(THEOS_MAKE_PATH)/tool.mk

#
# Copyright (C) 2026 TeamWin Recovery Project
# Licensed under the Apache License, Version 2.0
#
# 设备：Readboy C30 (msm8998) | 骁龙835 | Android 10 | 原生AB | Recovery-as-Boot | SAR
#

###########################################################################
# 基础平台配置（msm8998）
###########################################################################
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_VARIANT := generic
TARGET_BOARD_PLATFORM := msm8998
TARGET_BOARD_SUFFIX := _64

###########################################################################
# 原生AB分区 + Recovery-as-Boot + System-as-Root
###########################################################################
BOARD_USES_RECOVERY_AS_BOOT := true
TARGET_NO_RECOVERY := true
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
TARGET_COPY_OUT_VENDOR := vendor
ENABLE_VIRTUAL_AB := false
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS ?= boot system vendor

# AVB：已解BL锁的设备设为false即可；若开机提示AVB验证失败再改为true
BOARD_AVB_ENABLE := false
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

###########################################################################
# 预编译内核配置
# ⚠️ 必须将 boot.img 解包得到的 kernel 和 kernel_dtb 两个文件
#     放到设备树根目录（与本文件同级）
###########################################################################
TARGET_PREBUILT_KERNEL := device/Readboy/msm8998/kernel
TARGET_NO_KERNEL := false
BOARD_KERNEL_IMAGE_NAME := kernel
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

# ⚠️ 以下参数必须用你自己 boot.img 解包后 split_img 目录里的实际值！
#    用 AIK (Android Image Kitchen) 解包后查看对应 .txt 文件
BOARD_KERNEL_BASE := 0x80000000        # 来自 *-base.txt
BOARD_KERNEL_PAGESIZE := 4096          # 来自 *-pagesize.txt
BOARD_KERNEL_OFFSET := 0x00008000      # 来自 *-kernel_offset.txt
BOARD_RAMDISK_OFFSET := 0x01000000     # 来自 *-ramdisk_offset.txt
BOARD_TAGS_OFFSET := 0x00000100        # 来自 *-tags_offset.txt
# BOARD_BOOT_HEADER_VERSION := 2       # 若解包信息显示header v2则取消注释

# ⚠️ 必须填写：在安卓系统中执行 `cat /proc/cmdline` 获取完整内容后填入
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200,n8 androidboot.console=ttyMSM0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=1da4000.ufshc loop.max_part=7

BOARD_MKBOOTIMG_ARGS := \
    --base $(BOARD_KERNEL_BASE) \
    --pagesize $(BOARD_KERNEL_PAGESIZE) \
    --kernel_offset $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset $(BOARD_TAGS_OFFSET) \
    --dtb device/Readboy/msm8998/kernel_dtb

###########################################################################
# TWRP  Recovery 使用的 fstab
###########################################################################
TARGET_RECOVERY_FSTAB := device/Readboy/msm8998/twrp.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
TARGET_RECOVERY_UI_LIB := librecovery_ui_msm

###########################################################################
# ADB 与 USB
###########################################################################
TW_ADB_ENABLED := true
TW_ALWAYS_ENABLE_ADB := true
TW_ADB_INSECURE := true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 \
    service.adb.enable=1 \
    sys.usb.config=adb,mtp

TW_INCLUDE_USB := true
TW_INCLUDE_MTP := true
TW_INCLUDE_OTG := true
TW_INCLUDE_MASS_STORAGE := false
TW_USB_MTP_DRIVER := android
TW_NO_EXFAT_FUSE := false

###########################################################################
# TWRP 核心功能
###########################################################################
TW_THEME := portrait_hdpi
TW_NO_SCREEN_BLANK := true
TW_USE_TOOLBOX := true
TW_INCLUDE_BASH := true
TW_INCLUDE_NANO := true
TW_INCLUDE_TAR := true
TW_INCLUDE_ZIP := true
TW_INCLUDE_GZIP := true
TW_INCLUDE_XZ := true
BOARD_HAS_NO_SELECT_BUTTON := true

# 备份分区（AB设备自动处理槽位）
TW_BACKUP_VENDOR := true
TW_BACKUP_BOOT := true
TW_BACKUP_SYSTEM := true
TW_BACKUP_DATA := true
TW_BACKUP_CACHE := true
TW_BACKUP_MODEM := true

TW_INCLUDE_FORMAT_DATA := true
TW_INCLUDE_WIPE_CACHE := true
TW_INCLUDE_WIPE_DALVIK := true
TW_HAS_NO_REAL_PARTITIONS := false

###########################################################################
# Android 10 FBE 加密解密
###########################################################################
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
# ⚠️ 必须修改：设置 → 关于手机 → 安全补丁级别，完全一致的日期
PLATFORM_SECURITY_PATCH := 2019-09-05

###########################################################################
# 其他功能
###########################################################################
BOARD_HAS_DOWNLOAD_MODE := true
BOARD_HAS_FLASH_LED := true
TW_INCLUDE_VIBRATOR := true
TW_INCLUDE_SCREENSHOT := true
TW_INCLUDE_LOGCAT := true
TW_INCLUDE_REBOOT_BOOTLOADER := true
TW_INCLUDE_REBOOT_RECOVERY := true
TW_INCLUDE_REBOOT_SYSTEM := true
TW_INCLUDE_POWEROFF := true
TW_SELINUX_PERMISSIVE := true

###########################################################################
# TWRP 11 专属
###########################################################################
TW_SUPPORT_COMPRESSION := true
TW_USE_NEW_MAGISKBOOT := true
TW_INCLUDE_PROP_TOOLS := true
TW_INCLUDE_SELINUX_TOOLS := true

###########################################################################
# ⚠️ 屏幕参数：必须从你设备的 dts/iommu 或实际分辨率获取
#    当前为占位值，请替换为你设备的真实分辨率
###########################################################################
TW_SCREEN_WIDTH := 1600
TW_SCREEN_HEIGHT := 2560
TW_TOUCHSCREEN_WIDTH := 1600
TW_TOUCHSCREEN_HEIGHT := 2560
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 150

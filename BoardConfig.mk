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

# boot 分区大小（recovery-as-boot，boot.img 即 recovery）
# 实际生成约 52MB，设为 64MB；若刷入提示空间不足，在设备上执行
# blockdev --getsize64 /dev/block/bootdevice/by-name/boot 获取真实分区大小后替换
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864

# AVB：已解BL锁的设备设为false即可；若开机提示AVB验证失败再改为true
BOARD_AVB_ENABLE := false
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

###########################################################################
# 预编译内核配置（boot header v0，已通过 magiskboot unpack -h 确认）
#
# ⚠️ 重要：magiskboot unpack 会【自动解压】kernel！解包出的 kernel 是未压缩
#    ARM64 Image（约39MB，开头不是1f8b）。但原始 boot.img 里 kernel 是
#    gzip 压缩的（KERNEL_FMT=gzip），必须重新压缩，否则 bootloader 无法加载！
#
#    正确制作流程（在解包目录）：
#      gzip -n kernel                    # 未压缩Image → kernel.gz（约12.6MB）
#      cat kernel.gz kernel_dtb > kernel # 追加dtb，得到 Image.gz-dtb（约14.6MB）
#
#    验证最终 kernel：
#      head -c 2 kernel | xxd            # 必须显示 1f8b（gzip魔数）
#      ls -l kernel                      # 大小应接近 15320679
#
#    注意：不要定义 BOARD_INCLUDE_DTB_IN_BOOTIMG！AOSP 用 ifdef 判断，
#    即使设为 false 也会触发 dtb.img 依赖。
###########################################################################
TARGET_PREBUILT_KERNEL := device/Readboy/msm8998/kernel
TARGET_NO_KERNEL := false
BOARD_KERNEL_IMAGE_NAME := kernel

# v0 boot header 不存储偏移量，以下为 msm8998 平台标准默认值，直接使用即可
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_TAGS_OFFSET := 0x00000100

# 从 boot header 提取的原始 CMDLINE（magiskboot unpack -h 确认）
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200,n8 androidboot.console=ttyMSM0 earlycon=msm_serial_dm,0xc1b0000 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 sched_enable_hmp=1 sched_enable_power_aware=1 service_locator.enable=1 swiotlb=2048 androidboot.configfs=true androidboot.usbcontroller=a800000.dwc3 loop.max_part=7 buildvariant=user veritykeyid=id:7e4333f9bba00adfe0ede979e28ed1920492b40f

# v0 header 不支持 --dtb，DTB 已合并进 kernel 文件中
BOARD_MKBOOTIMG_ARGS := \
    --base $(BOARD_KERNEL_BASE) \
    --pagesize $(BOARD_KERNEL_PAGESIZE) \
    --kernel_offset $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset $(BOARD_TAGS_OFFSET)

###########################################################################
# TWRP  Recovery 使用的 fstab
###########################################################################
TARGET_RECOVERY_FSTAB := device/Readboy/msm8998/twrp.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
# 不设置 TARGET_RECOVERY_UI_LIB，使用 TWRP 默认 recovery UI（librecovery_ui_msm 无源码提供）

###########################################################################
# ADB 与 USB
###########################################################################
TW_ADB_ENABLED := true
TW_ALWAYS_ENABLE_ADB := true
TW_ADB_INSECURE := true

TW_INCLUDE_USB := true
TW_INCLUDE_MTP := true
TW_INCLUDE_OTG := true
TW_INCLUDE_MASS_STORAGE := false
TW_USB_MTP_DRIVER := android
TW_NO_EXFAT_FUSE := false

###########################################################################
# TWRP 核心功能
###########################################################################
TW_THEME := landscape_hdpi
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
BOARD_USES_QCOM_FBE_DECRYPTION := true
# 安全补丁日期：从 boot header OS_PATCH_LEVEL 确认 = 2019-09
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
# 屏幕参数：横屏 2560x1600（ts125qdm 12.5寸 split_dsi 面板，已确认）
###########################################################################
TW_SCREEN_WIDTH := 2560
TW_SCREEN_HEIGHT := 1600
TW_TOUCHSCREEN_WIDTH := 2560
TW_TOUCHSCREEN_HEIGHT := 1600
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 150

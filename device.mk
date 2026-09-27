# Copyright (C) 2026 TeamWin Recovery Project
# Licensed under the Apache License, Version 2.0
#

# 继承基础系统（不依赖 device/qcom/common，避免 Actions 构建器未自动克隆依赖导致编译失败）
# QCOM USB 初始化已由 init.recovery.qcom.rc 处理，TWRP 11 主源码含通用高通支持
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# 设备文件复制
# fstab.ab          → ramdisk 第一阶段挂载用（init 读取）
# init.recovery.qcom.rc → 从设备提取的 recovery 启动脚本
# 注意：twrp.fstab 不要手动复制到 etc/，会与基线 ramdisk 的 etc 符号链接冲突，
#       它由 BoardConfig 中的 TARGET_RECOVERY_FSTAB 自动处理
PRODUCT_COPY_FILES += \
    device/Readboy/msm8998/fstab.ab:root/fstab.ab \
    device/Readboy/msm8998/init.recovery.qcom.rc:root/init.recovery.qcom.rc

# 设备属性 + ADB 强制开启（PRODUCT_PROPERTY_OVERRIDES 只能在产品mk中设置，不能在BoardConfig中）
PRODUCT_PROPERTY_OVERRIDES += \
    ro.twrp.device.name=msm8998 \
    ro.twrp.vendor.name=Readboy \
    ro.product.device=msm8998 \
    ro.product.manufacturer=Readboy \
    ro.product.model=C30 \
    ro.twrp.build.type=unofficial \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 \
    service.adb.enable=1 \
    sys.usb.config=adb,mtp

# 解决"重启到系统/切槽失败"：提供 bootctl（TWRP 重启菜单的 Slot 切换/重启系统依赖它）
PRODUCT_PACKAGES += bootctl

# 高通 FBE 解密组件（配合 BoardConfig 的 BOARD_USES_QCOM_FBE_DECRYPTION）
# 自动生成 /init.recovery.qcom_decrypt.rc，负责启动 qseecomd / keymaster / gatekeeper
PRODUCT_PACKAGES_ENG += \
    qcom_decrypt \
    qcom_decrypt_fbe

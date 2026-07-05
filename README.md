# luci-app-pushbot (English)

[中文文档](README.md)

"PushBot" is a router status push notification plugin designed specifically for OpenWrt. It can push real-time information such as router IP changes, device online/offline status, CPU load, and device temperature directly to your various terminal devices.

## Acknowledgments & Declaration
The birth and continuous improvement of this plugin are inseparable from the contributions of the following open-source community authors. We extend our most sincere gratitude to:
- **[tty228](https://github.com/tty228/luci-app-serverchan)**: This plugin was originally developed based on `luci-app-serverchan`.
- **[zzsj0928](https://github.com/zzsj0928/luci-app-pushbot)**: When the limitations of the original WeChat push became apparent, it was refactored into `luci-app-pushbot`, expanding to include DingTalk, WeCom, and many other push channels.
- In this latest refactoring, built upon previous work, a **comprehensive Internationalization (i18n) standardization** has been implemented. All hardcoded Chinese characters have been completely removed, allowing the plugin to perfectly adapt to the language preferences of users across different countries and regions.

## 🌟 Latest Feature: Comprehensive i18n Support
Following the latest underlying refactoring, PushBot now fully adheres to OpenWrt's standard multi-language development specifications:
- **Web UI Localization**: All page text has been extracted into standard `.po` translation files, which automatically switch based on the current LuCI system language setting (e.g., if the system is in English, the plugin interface is fully English).
- **Backend Push Message Localization**: The script layer also implements dynamic language adaptation. When the router's backend detects a device dropping offline or an IP change, it reads the `luci.main.lang` setting to push message content that matches your interface language (say goodbye to receiving Chinese alerts on an English system).

## Supported Push Platforms
This plugin supports the vast majority of mainstream notification platforms:
- **DingTalk Bot** (钉钉机器人)
- **WeCom Bot / WeCom App** (企业微信)
- **Feishu Bot** (飞书机器人)
- **PushPlus** (Supports pushing to WeChat Official Accounts and group pushes)
- **Bark** (A custom notification service designed for iOS users, supporting custom icons/sounds)
- **PushDeer** (An app-less push service based on Apple App Clips)
- **Custom Webhook** (DIY interface, easily compatible with platforms like Telegram Bot, ServerChan, etc.)

## Core Features
- **Device Online/Offline Notifications**: Accurately pushes device alias, MAC address, and online time.
- **Traffic Abnormalities & Statistics**: Keep track of the traffic consumption of individual devices at any time.
- **Router Status Monitoring**: Alerts for IP/IPv6 address changes, high CPU temperature, and high system load.
- **Security Alerts**: Warnings for frequent SSH/Web login failures to prevent brute-force attacks.
- **Highly Customizable Do-Not-Disturb (DND) & Scheduled Tasks**.

## Installation & Dependencies
Because this plugin uses active probing to detect device connections, it must rely on the following components. Please ensure you have updated your router's software sources before installing:
- Core dependencies: `iputils-arping`, `curl`, `jq`
- Traffic statistics feature dependency: `wrtbwmon` (may conflict with some Flow Offloading configurations; install according to your situation).

### How to Compile:
```bash
git clone https://github.com/permails/luci-app-pushbot package/luci-app-pushbot
```
And ensure this is enabled in your `.config` configuration file:
```
CONFIG_PACKAGE_luci-app-pushbot=y
```

## Notes
- Using active probing avoids frequent false online/offline reports caused by device WiFi sleep. If your device experiences instability due to frequent sleeping, please adjust the timeout parameters in "Advanced Settings".
- When retrieving device names, the script reads `/var/dhcp.leases`. Devices with static IPs or behind a secondary router may not be able to obtain a hostname automatically. It is recommended to manually configure the "Device Alias (MAC Whitelist/Blacklist)" feature in the plugin.

---
*Issues and Pull Requests (PRs) are always welcome!*


---


[English](README_EN.md)

# luci-app-pushbot 

「全能推送」(PushBot) 是一款专为 OpenWrt 设计的路由器状态推送插件。它可以将路由器的 IP 变动、设备上下线、CPU 负载、设备温度等信息实时推送到您的各种终端设备上。

## 感谢与声明
本插件的诞生与持续完善离不开以下开源社区作者的贡献，在此致以最诚挚的感谢：
- 感谢 **[tty228](https://github.com/tty228/luci-app-serverchan)**：本插件最初基于 `luci-app-serverchan` 原创开发。
- 感谢 **[zzsj0928 (然后七年)](https://github.com/zzsj0928/luci-app-pushbot)**：在原版微信推送局限性渐显时，将其重构为 `luci-app-pushbot`，扩展了钉钉、企业微信等众多推送渠道。
- 本次重构在前人基础上，对代码进行了**全面的国际化 (i18n) 标准化适配**，彻底移除了硬编码的中文字符，使得插件能够完美自适应不同国家和地区用户的语言偏好。

## 🌟 最新特性：全面的国际化 (i18n) 支持
经过最新的底层重构，PushBot 现在完全遵循 OpenWrt 的标准多语言开发规范：
- **Web UI 多语言**：所有页面文案已抽离为标准的 `.po` 翻译文件，自动根据当前 LuCI 系统的语言设置切换（例如：系统为英文时，插件界面全英文）。
- **后台推送消息多语言**：脚本层同样实现了动态语言适配。当路由器后台探测到设备掉线或 IP 变动时，它会读取 `luci.main.lang` 设置，向您的手机推送符合您界面语言的消息内容（彻底告别在英文系统下收到中文报警的尴尬情况）。

## 支持的推送平台
本插件支持绝大多数主流通知平台：
- **钉钉机器人** (DingTalk)
- **企业微信机器人** / **企业微信应用** (WeCom)
- **飞书机器人** (Feishu)
- **PushPlus**（支持推送到微信公众号，支持一对多群组推送）
- **Bark**（专为 iOS 用户设计的自定义通知服务，支持自定义图标/声音）
- **PushDeer**（无 App 推送服务，基于苹果轻应用）
- **自定义 Webhook**（DIY 接口，轻松兼容 Telegram Bot、Server酱 等平台）

## 核心功能
- **设备上下线通知**：精准推送设备别名、MAC 地址、在线时间。
- **流量异常与统计**：随时掌握各个设备的流量消耗。
- **路由器状态监视**：IP/IPv6 地址变动、CPU 温度过高、系统负载过高报警。
- **安全预警**：SSH/Web 频繁登录失败提醒，防暴力破解。
- **高度可定制的免打扰与定时任务**。

## 安装与依赖
由于本插件底层使用主动探测设备连接的方式，所以必须依赖以下组件，安装前请确保您已经更新了路由器的软件源：
- 核心依赖：`iputils-arping`, `curl`, `jq`
- 流量统计功能依赖：`wrtbwmon`（与部分 Flow Offloading 可能会有冲突，请根据自己情况安装）。

### 编译拉取方法：
```bash
git clone https://github.com/permails/luci-app-pushbot package/luci-app-pushbot
```
并在 `.config` 配置文件中确保开启：
```
CONFIG_PACKAGE_luci-app-pushbot=y
```

## 注意事项
- 使用主动探测可避免因为设备 WiFi 休眠导致频繁的上下线误报。如果您的设备遇到休眠频繁导致的不稳定，请在“高级设置”中自行调整超时时间参数。
- 获取设备名称时，脚本会读取 `/var/dhcp.leases`。静态 IP 或处于二级路由下的设备可能无法自动获取主机名，建议您在插件中手动配置“设备别名 (MAC 黑白名单)”功能。

---
*欢迎各类 Issue 反馈与代码提交 (PR)！*

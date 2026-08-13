<div align="center">

# CLIProxy Dash

**A privacy-conscious Android dashboard for CLIProxyAPI account status and quota monitoring.**

[![Android Build](https://github.com/YXX168/CLIProxy-Dash/actions/workflows/build.yml/badge.svg)](https://github.com/YXX168/CLIProxy-Dash/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/YXX168/CLIProxy-Dash)](https://github.com/YXX168/CLIProxy-Dash/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.41.6-02569B?logo=flutter)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android)](https://www.android.com/)

[功能](#功能) · [安装](#安装) · [配置](#配置) · [隐私与安全](#隐私与安全) · [开发](#开发)

</div>

CLIProxy Dash 是面向 [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) 的 Android 管理端伴侣应用，安装后的应用名称为 **CLIProxy**。它将 Codex OAuth 账号状态、额度窗口、重置时间和近期请求活动集中展示在一个适合移动端查看的仪表盘中。

> 本项目是独立的社区客户端，不隶属于 CLIProxyAPI 或相关服务提供方。

## 功能

- 查看 Codex OAuth 账号、套餐与可用状态
- 展示 5 小时、周/月额度及重置时间
- 实时倒计时、账号详情与主动重置额度信息
- 汇总近期请求脉冲、趋势、成功率和异常时段
- 支持手动刷新、下拉刷新与自动刷新
- 查看配置型与 OAuth 凭据实际可用的模型，并按提供商分组
- 查看和管理客户端 API Key
- 提供深海控制台、能量核心两种显示模式
- 使用暗色霓虹玻璃拟态、柔和极光背景与系统触觉反馈
- 将 Management API 地址和管理密钥保存在 Android 安全存储中

## 安装

### GitHub Releases

从 [Releases](https://github.com/YXX168/CLIProxy-Dash/releases/latest) 下载最新版 ARM64 APK，并可使用同页提供的 SHA-256 文件校验完整性。

当前仅构建 `android-arm64`，适用于大多数现代 Android 手机。

正式版签名证书 SHA-256：

```text
C4:32:2F:65:9C:61:DF:7F:50:46:10:DD:FE:3B:37:E1:7C:26:1C:55:1A:6D:A3:1E:A0:AB:AC:3C:1D:2E:B9:91
```

### GitHub Actions

`main` 分支的成功构建会保留 30 天 Artifact。正式使用建议优先下载带版本号的 Release。

## 配置

首次启动时，填写自己的 CLIProxyAPI 实例地址和对应管理密钥，即可连接并查看账户状态。可以填写实例根地址，例如：

```text
https://proxy.example.com
http://192.168.1.10:8317
```

应用会自动补全 `/v0/management`，已经包含该路径的地址也可直接使用。

CLIProxyAPI 服务端需要启用 Management API。手机从其他设备连接时，还需要允许远程管理：

```yaml
remote-management:
  allow-remote: true
  secret-key: "请设置高强度管理密钥"
```

修改服务端配置后请按 CLIProxyAPI 的部署方式重启或重新加载服务。管理接口权限很高，不要直接暴露到公网；公网访问应使用 HTTPS，并配合防火墙、反向代理或 VPN 限制来源。

### 工具说明

- 模型列表会合并 `config` 中的配置型模型和 `/auth-files/models` 返回的凭据运行时模型；旧版服务端不支持后者时仍会显示配置型模型。
- API Key 工具管理的是客户端访问代理所用的 `api-keys`，不是 Management API 管理密钥。添加或删除会立即写入服务端配置。
- Android 客户端允许连接明文 HTTP，以兼容 CLIProxyAPI 默认的局域网部署；HTTP 只应在可信局域网或受保护隧道中使用，其他场景请使用 HTTPS。

## 隐私与安全

- Management API 地址与管理密钥由用户在设备端输入
- 两项配置均通过 `flutter_secure_storage` 保存，不写入源码或普通偏好
- 仓库不收集、不上传遥测数据
- 请仅连接你信任的 CLIProxyAPI 实例，并优先使用 HTTPS
- 不要在 Issue、截图或日志中公开真实地址、密钥、Token 或账户信息

> 提醒：本应用是管理工具，不应暴露在不受信任的网络环境中。服务端访问控制和网络安全仍由使用者负责。

## 开发

### 环境

- Flutter `3.41.6`
- Dart `3.11.4` 或与项目约束兼容的版本
- Android SDK
- JDK 17

### 本地验证

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --target-platform android-arm64
```

贡献代码前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)，版本变化参见 [CHANGELOG.md](CHANGELOG.md)。

## 技术栈

- Flutter / Dart
- Material 3
- `flutter_secure_storage`
- `http`
- `shared_preferences`

## 项目状态

当前版本：`1.0.1`

项目已进入正式维护阶段。欢迎通过 Issue 报告问题或提出建议。

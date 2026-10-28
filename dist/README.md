# 安装包

- `Coody-1.0.0-arm64.apk`：用于常见 Android ARM64 手机。
- `Coody-1.0.0-x64.apk`：用于 Android x86_64 模拟器。本次设备测试使用 Android 15 / API 35。

两个包均由 `lib/main.dart` 构建为 release 模式，使用开发签名，适合本地体验和验收；不含集成测试入口。正式发布前需配置生产签名和后端服务。

源码和项目架构说明位于上一级目录。首次进入引导页，登录页可选择 **Explore as a guest**。这是本地 UI 演示，所有付款及身份流程均为模拟。

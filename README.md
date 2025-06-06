# HEMS - Home Energy Management Services

一款 iOS 應用程式，旨在協助使用者追蹤與分析個人能源消耗狀況，並提供節能建議，提升日常生活中的能源使用效率。

## 專案簡介

本專案為 iOS 平台開發的能源管理應用，透過直觀的介面與圖表，讓使用者輕鬆了解每日能源使用情況，並根據分析結果採取相應的節能措施。

## 功能特色

- 能源使用追蹤：記錄每日能源消耗數據，並以圖表形式呈現。
- 節能建議：根據使用模式提供個人化的節能建議。
- 歷史數據分析：查看過去的能源使用趨勢，幫助用戶制定長期節能計劃。
- AI 用電分析：透過 AI 模型自動辨識異常用電模式，提供即時洞察與警示。
- 遠端家電控制：連接智慧插座與裝置，讓使用者可透過手機遠端開關家電，實現智慧節能。
- 提醒功能：設定提醒，提示用戶關閉未使用的電器設備

## 系統需求

- Xcode 12.0 或以上版本
- iOS 16.6 或以上版本

## 技術架構與使用套件

- **語言與框架**：
  - Swift 5
  - SwiftUI
- **功能模組與套件**：
  - `CocoaPods`：管理第三方套件依賴。
  - `CocoaMQTT`：實現 MQTT 通訊協議，進行設備控制與資料傳輸。
  - `CoreBluetooth`：實現藍牙連線與資料交換。
  - `SystemConfiguration.CaptiveNetwork`：Wi-Fi 熱點掃描與 SSID 讀取
  - `UserNotifications`：推播通知處理
  - `Reachability`：網路狀態監測
  - `Result API`：處理非同步操作的結果。
  - `QRCodeScanner`：掃描 QR Code，快速配對設備。
  - `Apple Notifications (APNs)`：推播通知，實時獲取設備狀態。

<!-- ## 快速啟動

```bash
# 1. 下載專案
git clone https://github.com/zhuang8026/iii-iOS-IOTController.git

# 2. 安裝 CocoaPods 套件
cd iii-iOS-IOTController
pod install

# 3. 開啟 Workspace 專案
open Sttptech_energy.xcworkspace
```

## 專案結構

```bash
iii-iOS-IOTController/
├── Sttptech_energy/              # App 主程式
├── Sttptech_energyTests/         # 單元測試
├── Sttptech_energyUITests/       # UI 測試
├── Pods/                         # CocoaPods 依賴套件
└── README.md
``` -->

## 主要開發者

| 姓名                      | GitHub                                       | 聯絡方式             |
| ------------------------- | -------------------------------------------- | -------------------- |
| 莊杰翰 (Chuang Chieh Han) | [@zhuang8026](https://github.com/zhuang8026) | chuang8026@gmail.com |

## 介面截圖

<!-- <p align="center">
  <img src="Images/login.png" alt="登入畫面" width="24%" style="margin-right: 10px;" />
  <img src="Images/temp.png" alt="溫濕度畫面" width="24%" style="margin-right: 10px;" />
  <img src="Images/ac.png" alt="空調控制畫面" width="24%" style="margin-right: 10px;" />
  <img src="Images/remote.png" alt="紅外線控制畫面" width="24%" />
</p> -->

<!-- ### 登入畫面
![AC Control](Images/login.png) -->

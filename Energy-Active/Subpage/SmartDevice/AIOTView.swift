//
//  ContentView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/14.
//

import SwiftUI

struct AIOTView: View {
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    @ObservedObject var mqttManager = MQTTManagerMiddle.shared

    @Binding var loginflag:Bool // true -> token已過期
    @Binding var robotIconDisplay:Bool // 機器人顯示控制
    @Binding var showAIOTFullScreen:Bool // 智慧控制全螢幕控制（默認：關閉）
    
    @State private var selectedTab = "" // 選擇設備控制
    @State private var status = false // 控制顯示標題名稱（內含 返回 icon）
    @State private var enterBinding = false // 強制進入綁定畫面
    @State private var isShowingSmartControl = false // [pop-up] 是否要開始 智慧環控連線 頁面，默認：關閉
    @State private var isSmartControlConnected = false // [status] 連線狀態，默認：API GET 告知
    
    //    @AppStorage("isTempConnected")
    @State private var isTempConnected = false   // ✅ 溫濕度 記住連線狀態
    //    @AppStorage("isACConnected")
    @State private var isACConnected = false    // ✅ 冷氣 記住連線狀態
    //    @AppStorage("isDFConnected")
    @State private var isDFConnected = false     // ✅ 除濕機 記住連線狀態
    //    @AppStorage("isREMCConnected")
    @State private var isREMCConnected = false   // ✅ 遙控器 記住連線狀態
    //    @AppStorage("isESTConnected")
    @State private var isESTConnected = true    // ✅ 插座 記住連線狀態
    
    let tabToDeviceKey: [String: String] = [
        "空調": "air_conditioner",
        "除濕機": "dehumidifier"
    ]
    
    // 根據 selectedTab 動態決定 `status`
    private func bindingForSelectedTab() -> Binding<Bool> {
        switch selectedTab {
        case "溫濕度":
            return $isTempConnected
        case "空調":
            return $isACConnected
        case "除濕機":
            return $isDFConnected
        case "遙控器":
            return $isREMCConnected
        case "插座":
            return $isESTConnected
        default:
            return .constant(false)
        }
    }
    
    // 判斷設備是否已被綁定
    private func deviceBindingForTab(tab: String) -> Bool {
        // 將 tab 名稱對應到實際裝置的 MQTT key
        let tabToDeviceKey: [String: String] = [
            "溫濕度": "sensor",
            "空調": "air_conditioner",
            "除濕機": "dehumidifier",
            "遙控器": "remote"
        ]
        // 取得對應 MQTT 裝置資料（deviceData 為 [String: electricData]）
        guard let deviceKey = tabToDeviceKey[tab]
        else {
            // 若找不到 key 或資料，視為離線
            return false
        }
        return mqttManager.availables.contains(deviceKey)
    }
    
    // 根據 tab 判斷對應裝置是否在 30 分鐘內有更新（即是否在線）
    // - Parameter tab: UI 分頁名稱，例如 "溫濕度"
    // - Returns: 若裝置在 30 分鐘內有回傳資料，回傳 true（在線），否則 false（離線）
    // - Returns: 畫面正常 (true)、設備未連線 (false)
    private func isDeviceUpdatedOnline(tab: String) -> Bool {
        // 將 tab 名稱對應到實際裝置的 MQTT key
        let tabToDeviceKey: [String: String] = [
            "溫濕度": "sensor",
            "空調": "air_conditioner",
            "除濕機": "dehumidifier",
            //            "遙控器": "remote"
        ]
        
        // 取得對應 MQTT 裝置資料（deviceData 為 [String: electricData]）
        guard let deviceKey = tabToDeviceKey[tab],
              let deviceData = mqttManager.appliances[deviceKey],
              let updatedTime = deviceData["updated"]
        else {
            // 若找不到 key 或資料，視為離線
            return false
        }
        
        // 建立 ISO8601 格式的解析器（支援毫秒）
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 8 * 3600) // 台灣時區 +8
        
        // 將 updated 字串轉為 Date 物件（若格式錯誤則離線）
        guard let updatedDate = formatter.date(from: updatedTime.updated) else {
            return false
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(updatedDate)
        
        // 若差距在 30 分鐘內，代表在線，否則離線
        // 判斷是否在 5 分鐘內
        if timeInterval <= 1800 {
            print("✅ \(tab) 數據在 30 分鐘內更新")
        } else {
            print("⚠️ \(tab) 數據超過 30 分鐘未更新")
        }
        return timeInterval <= 1800 // 30分鐘 = 1800秒
    }
    
    // 判斷設備是否 綁定 或 設備上線
    private func isBindingOrOUpdated(tab: String) -> Bool {
        // 插座、遙控器 不會收到設備更新資料影響，
        if selectedTab == "插座" || selectedTab == "遙控器" {
            return true
        } else {
            let isBinding: Bool = deviceBindingForTab(tab: tab) // 已綁定設備資料
            let isUpdated: Bool = isDeviceUpdatedOnline(tab: tab) // 已綁定設備 資料更新時間 (<= 30 min)
            
            print("\(tab) 是否已經綁定 -> \(isBinding)")
            print("\(tab) 更新資料是否在30min之內 -> \(isUpdated)")
            return isBinding ? isUpdated : true // 有綁定 -> 檢查資料， 無綁定 -> 去畫面綁定
        }
        
    }
    
    // 判斷MQTT設備是否有回傳資料
    // 1. update = nil -> true -> loading
    // 2. sensor = nil -> true -> loading
    private func isMQTTManagerLoading(tab: String) -> Bool {
        switch tab {
        case "溫濕度":
            return mqttManager.appliances["sensor"]?["updated"]?.value == nil
        case "空調":
            return mqttManager.appliances["air_conditioner"]?["updated"]?.value == nil
        case "除濕機":
            return mqttManager.appliances["dehumidifier"]?["updated"]?.value == nil
        case "遙控器":
            return mqttManager.appliances["remote"]?["updated"]?.value == nil
        case "插座":
            return false
        default:
            return false
        }
    }
    
    // 設備綁定紀錄
    // 1. time >  5min -> loading no
    // 2. time <= 5min -> loading yes
    // 3. null         -> loading no
    private func isDeviceRecordToLoading(tab: String) -> Bool {
        switch tab {
            case "空調", "除濕機":
                let tabToDeviceKey: [String: String] = [
                    "空調": "air_conditioner",
                    "除濕機": "dehumidifier"
                ]
                guard let deviceKey = tabToDeviceKey[tab],
                      let updatedTime = mqttManager.appBinds[deviceKey] as? String,
                      !updatedTime.isEmpty,
                      let updatedDate = DateUtils.parseISO8601DateInTaiwanTimezone(from: updatedTime) else {
                    print("\(tab) 上線紀錄時間為空")
                    return false
                }
                
                let now = Date()
                let timeInterval = now.timeIntervalSince(updatedDate)
                
                // 檢查紀錄資料時間 <= 5min
                let recordTime: Bool = timeInterval <= 300
                if timeInterval <= 300 {
                    print("✅ \(tab) 紀錄時間在 5 分鐘內更新")
                } else {
                    print("⚠️ \(tab) 紀錄時間超過 5 分鐘未更新")
                }

                // 檢查資料 <= 30min
                let isUpdated: Bool = isDeviceUpdatedOnline(tab: tab)
                
                //  檢查資料 <= 30min ? no loading : ( 檢查紀錄資料時間 <= 5min ? loading : no loading )
                return isUpdated ? false : recordTime
                
            case "溫濕度", "遙控器", "插座":
                return false
            default:
                return false
        }
    }
    
    var body: some View {
        ZStack() {
//            if(appStore.userToken == nil) {
//                ZStack(){
//                    // 關閉 登入畫面
//                    // UserLogin()
//                }
//            } else {
                VStack(spacing: 20) {
                    // ✅ 傳遞 selectedTab 和 status
                    HeaderName(
                        selectedTab: $selectedTab, // title
                        status: bindingForSelectedTab(), // 顯示內容控制
                        enterBinding: $enterBinding, // 關閉 設備未連線
                        showAIOTFullScreen: $showAIOTFullScreen
                    )
                    
                    // 測試使用，可去除
                    // Text(mqttManager.loginResponse ?? "等待登入回應...")
                    // Text(isDeviceUpdatedOnline(tab: selectedTab) ? "畫面正常顯示" : "已離線")
                    
                    if(isSmartControlConnected) {
                        VStack() {
                            // 設備已綁定環控，進入 主要控制畫面
                            if isBindingOrOUpdated(tab: selectedTab) || self.enterBinding {
                                ZStack() {
                                    /// ✅ 設備已連線
                                    VStack() {
                                        // 根據 selectedTab 顯示對應元件
                                        switch self.selectedTab {
                                        case "溫濕度":
                                            Temperature(isConnected: $isTempConnected)
                                        case "空調":
                                            AirConditioner(isConnected: $isACConnected, enterBinding: self.enterBinding)
                                        case "除濕機":
                                            Dehumidifier(isConnected: $isDFConnected, enterBinding: self.enterBinding)
                                        case "遙控器":
                                            RemoteControl(isConnected: $isREMCConnected)
                                        case "插座":
                                            ElectricSocket()
                                        default:
                                            Spacer()
                                            Loading(text: "Loading..")
                                            Spacer()
                                        }
                                    }
                                    
                                    // enterBinding -> 強制進入綁定按鈕使用
                                    // true  -> 進入綁定 不顯示 loading
                                    // false -> 不進入綁定 顯示 loading
                                    //                                    if !self.enterBinding {
                                    // 條件一：❌ 無資料 → 顯示 Loading 畫面
                                    if isMQTTManagerLoading(tab: selectedTab) {
                                        Color.light_green
                                            .opacity(0.85) // 透明磨砂黑背景
                                            .edgesIgnoringSafeArea(.all) // 覆蓋整個畫面
                                        Loading(
                                            text: "載入\(selectedTab)資料中...",
                                            color: Color.g_blue
                                        )
                                    }
                                    
                                    // 先判斷 資料<=30min,再判斷記錄時間<=5min
                                    if isDeviceRecordToLoading(tab: selectedTab) {
                                        // 資料更新時間 <= 30min
                                        // 處理 loading 狀態中
                                        Color.light_green
                                            .opacity(0.85) // 透明磨砂黑背景
                                            .edgesIgnoringSafeArea(.all) // 覆蓋整個畫面
                                        Loading(
                                            text: "檢查\(selectedTab)資料中...",
                                            color: Color.g_blue
                                        )
                                    }
                                    
                                }
                            } else {
                                // 設備未連線
                                VStack {
                                    Spacer()
                                    Image("unconnect")
                                    Text("設備未連線")
                                        .font(.system(size: 14)) // 调整图标大小
                                        .multilineTextAlignment(.center)
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("1.請確認設備的網路連線是否正常運作")
                                        if self.selectedTab == "空調" || self.selectedTab == "除濕機" {
                                            Text("2.點擊右上角的按鈕重新嘗試連接")
                                        }
                                    }
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.warning)
                                    .padding() // ✅ 內部 padding：文字不貼邊
                                    .frame(alignment: .leading) // ✅ 撐滿寬度 + 左對齊
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal) // ✅ 外部 padding：框不貼螢幕邊
                                    Spacer()
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                            }
                            
                            Spacer()
                            
                            // 底部導航欄
                            NavigationBar(selectedTab: $selectedTab)
                                .environmentObject(mqttManager) // 確保能讀取 mqttManager
                                .onChange(of: self.selectedTab) { _ in
                                    self.enterBinding = false // 取消「強制轉綁定頁面」
                                }
                        }
                    } else {
                        ZStack() {
                            // ✅ 智能環控 連結
                            AddSmartControlView(
                                isShowingSmartControl: $isShowingSmartControl,  // 是否要開始 智慧環控連線 頁面，默認：關閉
                                isConnected: $isSmartControlConnected // 連線狀態
                            )
                            
                            // ❌ 無資料 → 顯示 Loading 畫面
                            if (mqttManager.serverLoading) {
                                Color.light_green.opacity(0.95) // 透明磨砂黑背景
                                    .edgesIgnoringSafeArea(.all) // 覆蓋整個畫面
                                Loading(text: "環控確認中...",color: Color.g_blue)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.light_green.opacity(1))
                .animation(.easeInOut, value: appStore.showPopup)
                .onAppear {
                    // mqttManager.connectMQTT() // 當 isConnected 變為 true，啟動 MQTT
                    mqttManager.connect()// 啟動 MQTT
                    // MARK: 機器人圖示為關閉
                     self.robotIconDisplay = false
                }
                .onDisappear {
                    mqttManager.disconnect() // 離開畫面 斷開 MQTT 連線
                }
                .onChange(of: mqttManager.isConnected) { newConnect in
                    print("[入口] isConnected: \(newConnect)")
                    // 連線MQTT
                    if newConnect {
                        // MARK: - token 傳到後端儲存
                        mqttManager.setDeviceToken(deviceToken: DeviceToken)
                        //  mqttManager.publishApplianceUserLogin(username: "app", password: "app:ppa")
                        //  MQTTManagerMiddle.shared.login(username: "user", password: "app:ppa")
                        //  mqttManager.publishTelemetryCommand(subscribe: true)

                        // MARK: - 接收家電資訊指令
                        mqttManager.startTelemetry() // 接收家電資訊指令
                        //  mqttManager.publishCapabilities()

                        // MARK: -查詢 家電參數讀寫能力 指令
                        mqttManager.requestCapabilities() // 查詢 家電參數讀寫能力 指令
                    }
                }
                .onReceive(mqttManager.$isSmartBind) { newValue in
                    print("[入口] 智能環控綁定狀態: \(newValue)")
                    isSmartControlConnected = newValue // 連動 智能環控 綁定
                }
                .onReceive(mqttManager.$availables) { availables in
                    print("已綁定家電列表:\(availables)")
                    isTempConnected = availables.contains("sensor")
                    isACConnected = availables.contains("air_conditioner")
                    isDFConnected = availables.contains("dehumidifier")
                    isREMCConnected = availables.contains("remote")
                }
                .onReceive(mqttManager.$responseCode) { responseCode in
                    print("錯誤代碼:\(responseCode ?? 000)")
                    if(responseCode == 4002) {
                        self.loginflag = true
                    }
                }
                // [全局][自訂彈窗] 提供空調 與 遙控器 頁面使用
                if mqttManager.decisionControl {
                    CustomPopupView(
                        isPresented: $mqttManager.decisionControl,
                        // 開關
                        title: appStore.title,
                        message: mqttManager.decisionMessage,
                        onConfirm: {
                            mqttManager
                                .setDecisionAccepted(
                                    accepted: true
                                ) // [MQTT] AI決策
                            mqttManager.decisionEnabled = true
                        },
                        onCancel: {
                            mqttManager
                                .setDecisionAccepted(
                                    accepted: false
                                ) // [MQTT] AI決策
                        }
                    )
                }
//            }
        }
    }
}

//#Preview {
//    ContentView()
//}

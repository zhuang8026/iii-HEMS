//
//  Energy_ActiveApp.swift
//  Energy-Active
//
//  Created by IIIai on 2023/3/6.
//

import SwiftUI

@main
struct Energy_ActiveApp: App {
    
    // MARK: 警告視窗 & 每週提示視窗 & 每日登入提示視窗
    @StateObject var electricityElectricityTrackingAlertManager = ElectricityTrackingAlertManager()
    
    // MARK: 目標額度提示視窗
    @StateObject var electricityModifyElectricityTargetAlertManager = ModifyElectricityTargetAlertManager()
    
    @StateObject var electricityGraphicsAlertManager = GraphicsAlertManager()
    @StateObject var electricity_MsgManager = Electricity_MsgManager()
    @StateObject var electricityScheduleManager = ElectricityScheduleManager()
    @StateObject var electricityCreateReviseScheduleManager = CreateReviseScheduleManager()
    @StateObject var electricityCustomAlertManager = CustomAlertManager()
    @StateObject var electricityCustomDeleteAlertManager = CustomDeleteAlertManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appStore = AppStore()  // 全域狀態管理
    @StateObject private var mqttManager = MQTTManagerMiddle.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(electricityElectricityTrackingAlertManager)
                .environmentObject(electricityModifyElectricityTargetAlertManager)
            
                .environmentObject(electricityGraphicsAlertManager)
                .environmentObject(electricity_MsgManager)
                .environmentObject(electricityScheduleManager)
                .environmentObject(electricityCreateReviseScheduleManager)
                .environmentObject(electricityCustomDeleteAlertManager)
                .environmentObject(electricityCustomAlertManager)
            
                .environmentObject(appStore)  // ✅ 注入 appStore 傳遞全域狀態
                .environmentObject(mqttManager) // ✅ 注入 MQTTManager 讓所有頁面都能使用
            
                .environment(\.sizeCategory, .medium)
                .onAppear {
                    // 在 App 啟動時確認通知設定狀態
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        
                        switch settings.authorizationStatus {
                        case .notDetermined:
                            
                            // 如果還沒有授權，則進行授權請求
                            print("如果還沒有授權，則進行授權請求")
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                                if granted {
                                    DispatchQueue.main.async {
                                        UIApplication.shared.registerForRemoteNotifications()
                                    }
                                }
                            }
                        case .denied:
                            print("通知權限被拒絕")
                        case .authorized:
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        default:
                            break
                        }
                    }
                    
                    
                    // MARK: 設置徽章為 0，避免開啟 App 時還顯示未清除的徽章
                    // UIApplication.shared.applicationIconBadgeNumber = 0
                    
                    // MARK: 啟動 MQTT
//                    mqttManager.connect()
                }
//                .onChange(of: mqttManager.isConnected) { newConnect in
//                    print("[入口] isConnected: \(newConnect)")
//                    // 連線MQTT
//                    if newConnect {
//                        // MARK: token 傳到後端儲存
//                        mqttManager.setDeviceToken(deviceToken: DeviceToken)
//                    }
//                }
        }
    }
    
}


//MARK: 實作 AppDelegate 來註冊 APNS
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // 註冊推播通知並請求權限
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ 使用者同意推播")
                //MARK: -  向 APNs 註冊
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("推播通知權限未授權或授權過程發生錯誤：\(error?.localizedDescription ?? "")")
            }
        }
        return true
    }
    
    // MARK: - 成功註冊推播 & 設置徽章數量，取得 device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 將 token 傳送至伺服器
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        DeviceToken = token
        print("📱 Device Token: \(token)")
        
//        MQTTManagerMiddle.shared.setDeviceToken(deviceToken: DeviceToken)

        // 設置初始徽章數為 0
        //application.applicationIconBadgeNumber = 0
    }
    
    // 推播註冊失敗
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ 無法註冊 APNs: \(error.localizedDescription)")
    }

    // 接收到通知時更新徽章數
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("✅ 前景收到推播資料: \(userInfo)")

        // 設置徽章數量
        UIApplication.shared.applicationIconBadgeNumber = 1
        
        completionHandler()
    }
    
    // [Testing] Apple Push Notifications 測試
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        // 前景通知顯示橫幅 + 聲音 + 徽章
//        completionHandler([.banner, .sound, .badge])
//    }
    
}

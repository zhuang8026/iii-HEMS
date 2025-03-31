//
//  ContentView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/3/6.
//

import SwiftUI
import UserNotifications


struct ContentView: View {

    @State var loginflag = true
    @State var robotIconDisplay = false
    @State var selection = 0
    @State var forapp = Forapp()
    @State private var isChatViewPresented = false // 子頁面控制器（默認：關閉）
    
    
    @EnvironmentObject var electricityElectricityTrackingAlertManager : ElectricityTrackingAlertManager
    @EnvironmentObject var electricityModifyElectricityTargetAlertManager : ModifyElectricityTargetAlertManager
    
    @EnvironmentObject var electricityGraphicsAlertManager : GraphicsAlertManager
    @EnvironmentObject var electricity_msgManager : Electricity_MsgManager
    @EnvironmentObject var electricityScheduleManager : ElectricityScheduleManager
    @EnvironmentObject var createReviseScheduleManager : CreateReviseScheduleManager
    @EnvironmentObject var electricityCustomAlertManager : CustomAlertManager
    @EnvironmentObject var electricityCustomDeleteAlertManager : CustomDeleteAlertManager
    
    
    // MARK: 宣告初始值
//    @State var showModifyElectricityTargetView : Bool = false
    
    // MARK: 宣告Socket
    @StateObject var socketManager = AppSocketManager()
    
        
    var body: some View {
                
        ZStack{
            if loginflag{
                LoginView(loginflag: self.$loginflag)
            }
            else{     
                Group{
                    TabView {
                        ElectricityTrackingView(loginflag: self.$loginflag, robotIconDisplay: self.$robotIconDisplay, forapp: self.$forapp, socketManager: socketManager)
                        //                    ElectricityTrackingWebView(loginflag: self.$loginflag)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("日常用電追蹤")
                            }.badge(forapp.User_advice_bt) //勳章顯示相關功能

                        HomeEnergyReportView(loginflag: self.$loginflag, robotIconDisplay: self.$robotIconDisplay, forapp: self.$forapp)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tabItem {
                                Image(systemName: "rectangle.3.group.bubble")
                                Text("家庭能源報告")
                            }.badge(forapp.Weekly_monthly_report_bth) //勳章顯示相關功能

                        ElectricityManageView(loginflag: self.$loginflag, robotIconDisplay: self.$robotIconDisplay, forapp: self.$forapp)
                        //                    ElectricityManageWebUIView(loginflag: self.$loginflag)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tabItem {
                                Image(systemName: "bolt.circle.fill")
                                Text("管理用電")
                            }.badge(forapp.Manage_control_advice_bth) //勳章顯示相關功能

                        ElectricityManageView(loginflag: self.$loginflag, robotIconDisplay: self.$robotIconDisplay, forapp: self.$forapp)
                        //                    ElectricityManageWebUIView(loginflag: self.$loginflag)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tabItem {
                                Image(systemName: "bolt.horizontal.icloud.fill")
                                Text("智慧控制")
                            }.badge(forapp.Manage_control_advice_bth) //勳章顯示相關功能

                        CustomerServiceView(loginflag: self.$loginflag, robotIconDisplay: self.$robotIconDisplay)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("帳戶服務")
                            }
                    }
                    
                    
                    if(robotIconDisplay)
                    {
                        // MARK: 在右下角添加一個固定的黃色按鈕
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    isChatViewPresented = true
                                }) {
                                    Image(socketManager.robotExceptionIcon ? "chat-bot-Warning" : "chat-bot")
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                .sheet(isPresented: $isChatViewPresented) {
                                    ChatView(socketManager: socketManager)
                                }
                                .padding(.trailing, 0) // 右邊距離
                                .padding(.bottom, 33) // 底部距離
                                .disabled(socketManager.socketReady)
                            }
                        }.ignoresSafeArea(.keyboard, edges: .bottom) // 禁用自動避開鍵盤
                    }
                }                
                // MARK: - 設定用電目標額度提示視窗
                .electricityModifyElectricityTargetAlertView(showAlert: $electricityModifyElectricityTargetAlertManager.showAlert,
                                                                totalTarget: $electricityModifyElectricityTargetAlertManager.totalTarget,
                                                                mouthKwh: $electricityModifyElectricityTargetAlertManager.mouthKwh,
                                                                useTargetRatio: $electricityModifyElectricityTargetAlertManager.useTargetRatio)
                
                // MARK: - 警告視窗
                .electricityWarningCustomAlertView(showAlert: $electricityElectricityTrackingAlertManager.showWarningCustomAlert, currentData: $electricityElectricityTrackingAlertManager.currentData, forapp: self.$forapp)
                
                // MARK: - 每週提示視窗
                .electricityWeekly_MsgAlertView(showAlert: $electricityElectricityTrackingAlertManager.showWeekly_MsgAlert,
                    performance: "", weekly_advice: "")
                
                // MARK: - 每日登入提示視窗
                .electricityContinuousLoginAlertView(showAlert: $electricityElectricityTrackingAlertManager.showContinuousLoginAlert, loginday: 0)
                
                .environmentGraphicsAlertView(loginflag: self.$loginflag, showAlert: $electricityGraphicsAlertManager.showAlert)
                .environmentElectricity_MsgAlertView(showAlert: $electricity_msgManager.showAlert)
                .environmentElectricityScheduleView(loginflag: self.$loginflag, showAlert: $electricityScheduleManager.showAlert, 
                                                    isHistoryPage: $electricityScheduleManager.isHistoryPage)
                .environmentCreateReviseScheduleView(loginflag: self.$loginflag, showAlert: $createReviseScheduleManager.showAlert,
                                                    isCreateSchedule: $createReviseScheduleManager.isCreateSchedule, 
                                                    currentTime: $createReviseScheduleManager.currentSchedDate)
                .environmentCustomDeleteAlertView(isPresented: $electricityCustomDeleteAlertManager.isPresented)
                .environmentCustomAlertView(isPresented: $electricityCustomAlertManager.isPresented, 
                                            message: $electricityCustomAlertManager.message)
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
    static let cloloABC = Color(hex: "#FFFFFF", alpha: 0.5)

    init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        assert(hex.count == 3 || hex.count == 6 || hex.count == 8, "Invalid hex code used. hex count is #(3, 6, 8).")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(alpha)
        )
    }
}

struct Forapp {
    var User_advice_bt = 0
    var Weekly_monthly_report_bth = 0
    var Manage_control_advice_bth = 0
}

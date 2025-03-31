//
//  ElectricityManageView.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/7.
//

import SwiftUI

struct ElectricityManageView: View {
    
    @EnvironmentObject var progressManager : ProgressManager
    @EnvironmentObject var electricity_msgManager : Electricity_MsgManager
    @EnvironmentObject var electricityScheduleManager : ElectricityScheduleManager
    @Binding var loginflag:Bool
    @Binding var robotIconDisplay:Bool
    @Binding var forapp:Forapp
    @State var isLoaded = false
    @State var ScheduleDevices = [ScheduleDeviceStruct]()
    @State var showScheduleAlert : Bool = false
    @State var showWarningIcon : Bool = false
    @State var ElectricityMsgArray = [ElectricityMsgInfo]()
            
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        ZStack{
            VStack{
                VStack{
                    Image("top-title").resizable().scaledToFit()
                        .foregroundColor(.clear)
                        .frame(width: 177.0, height: 27)
                }.frame(height: 50.0)
                
                ScrollView{
                    Group {
                        HStack(alignment: .bottom){
                            Text("管理用電").font(.custom("NotoSansTC-Bold", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(NavyBlueCustomizeColor)
                                            
                            ZStack{
                                Circle()
                                    .foregroundColor(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                                    .frame(width: 30.0, height: 30.0)
                                
                                Button {
                                    print("按下 管理用電 鈴鐺icon")
                                    self.electricity_msgManager.ElectricityMsg = ElectricityMsgArray
                                    //if electricity_msgManager.ElectricityMsg.count > 0 {
                                    //}
                                    self.electricity_msgManager.showAlert = true
                                    
                                } label: {
                                    Image("bell").resizable()//.scaledToFit(s)
                                        .frame(width: 20.0, height: 20.0)
                                }
                                
                                if(self.showWarningIcon)
                                {
                                    Circle()
                                        .foregroundColor(Color(red: 1.0, green: 96.0 / 255.0, blue: 96.0 / 255.0))
                                        .frame(width: 8.0, height: 8.0)
                                        .offset(x: 10, y: -10)
                                }
                            }.frame(width: 30.0, height: 30.0)
                                .padding(.leading, 15)
                            
                            Spacer()
                        }.padding(.horizontal, 12)
                    }
                    
                    if(self.isLoaded)
                    {
                        
                        ForEach(0..<ScheduleDevices.count, id: \.self){  index in
                            ScheduleDeviceUIView(showAlert: $showScheduleAlert, deviceData: ScheduleDevices[index])
                                .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
                        }
                        
                    }
                    else {
                
                        ScheduleDeviceUIView(showAlert: $showScheduleAlert, deviceData: ScheduleDeviceStruct(devId: "IN00----DDDDD0D0DD0D",
                                                                                                             devName: "電器一", devType: "N/A",
                                                                                                             activePower: "0.0", applianceType: "0",
                                                                                                             connectionStatus: "0", powerStatus: "0",
                                                                                                             schedulesCount: "0",
                                                                                                             schedulesExecutingCount: "0"))
                        .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
                        
                        ScheduleDeviceUIView(showAlert: $showScheduleAlert, deviceData: ScheduleDeviceStruct(devId: "IN00----DDDDD0D0DD0D",
                                                                                                             devName: "電器二", devType: "N/A",
                                                                                                             activePower: "0.0", applianceType: "0",
                                                                                                             connectionStatus: "0", powerStatus: "0",
                                                                                                             schedulesCount: "0",
                                                                                                             schedulesExecutingCount: "0"))
                        .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
                      
                        
                    }
                }
                
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
//            if showElectricity_MsgAlert
//            {
//                Electricity_MsgAlert(showAlert: $showElectricity_MsgAlert, ElectricityMsg: ElectricityMsgArray)
//            }
            
            //讀取狀態轉圈圈
            if(!self.isLoaded){
    
                Color.init(hex: "#f3f3f3", alpha: 0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
                    .scaleEffect(2)
            }
        }
        .onChange(of: self.electricity_msgManager.showAlert){value in
            if(!value)
            {
                // 從建議回來
                print("回到主畫面刷新開始")// + String(value))
                print("進入用電管理頁面")
                
                self.isLoaded = false
                self.showWarningIcon = false
                
                
                Task{
                    //MARK: 取得通知勳章個數
                    await GET_URLRequest_Forapp()
                }
                
                Task{
                    //MARK: 取得用電管理建議
                    await GET_URLRequest_AdvMsg()
                }
                
                Task{
                    //MARK: 取得用電管理資訊
                    await GET_URLRequest_Cloid_Remote()
                }
                
                            }
        }
        .onChange(of: electricityScheduleManager.showAlert){value in
            if(!value)
            {
                print("回到主畫面刷新開始")
                print("進入用電管理頁面")
                
                self.isLoaded = false
                self.showWarningIcon = false
                                
                Task{
                    //MARK: 取得用電管理建議
                    await GET_URLRequest_AdvMsg()
                }
                
                Task{
                    //MARK: 取得用電管理資訊
                    await GET_URLRequest_Cloid_Remote()
                }
            }
        }
        
        .onAppear{
            
            print("進入用電管理頁面")
            
            self.isLoaded = false
            self.showWarningIcon = false
            // MARK: 機器人圖示為開啟
            self.robotIconDisplay = true
            
            Task{
                //MARK: 取得用電管理建議
                await GET_URLRequest_AdvMsg()
            }
            
            Task{
                //MARK: 取得用電管理資訊
                await GET_URLRequest_Cloid_Remote()
            }
        }
        .environmentObject(electricity_msgManager)
    }
    
    // MARK: - 管理用電(嵌入)-設備列表(三個插座)
    func GET_URLRequest_Cloid_Remote() async {
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let url = PocUrl + "api/main/cloud-remote"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET cloud-remote)")
            //                print(response)
            //                print(data)
            
            // MARK: 解析json
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
//                let message = json?["message"] as? String
                //                    print("code: \(code)")
                //                    print("message: \(message)")
                
                //                    print("GET_URLRequest_Current_Mon get token : ", token)
                
                if(code == 200){
                    // MARK: 取得管理用電個別資訊
                    if let dataDict = json?["data"] as? [String: Any], let _result = dataDict["scheduleDevices"] as? [[String: Any]] {
                        
                        //先清除舊的
                        DispatchQueue.main.async {
                            
                            ScheduleDevices = [ScheduleDeviceStruct]()
                            
                            for item in _result{
                                
                                var d : ScheduleDeviceStruct = ScheduleDeviceStruct()
                                d.devId = item["devId"] as? String
                                d.devName = item["devName"] as? String
                                d.devType = item["devType"] as? String
                                d.activePower = item["activePower"] as? String
                                d.applianceType = item["applianceType"] as? String
                                d.connectionStatus = item["connectionStatus"] as? String
                                d.powerStatus = item["powerStatus"] as? String
                                                                
                                let schedulesCountInt = item["schedulesCount"] as? Int
                                d.schedulesCount = String(schedulesCountInt ?? 0)                                
                                d.scheduleInfoList = item["scheduleInfoList"] as? [String]
                                
                                //取得幾個排程執行中
                                var schedulesExecutingCount = 0
                                if let _infoList = item["scheduleInfoList"] as? [[String: String]] {
                                    for index in _infoList{
                                        if(index["enable"] == "yes") {
                                            schedulesExecutingCount+=1
                                        }
                                    }
                                }
                                d.schedulesExecutingCount = String(schedulesExecutingCount)
                                                                
//                                print("devName : " + (d.devName ?? "N/A"))
//                                print("powerStatus : " + (d.powerStatus ?? "N/A"))
//                                print("connectionStatus : " + (d.connectionStatus ?? "N/A"))
//                                print("activePower : " + (d.activePower ?? "N/A"))
//                                print("schedulesCount : " + (d.schedulesCount ?? "N/A"))
//                                print("scheduleInfoList : " + (d.scheduleInfoList ?? "null"))
//                                print("schedulesExecutingCount : " + (d.schedulesExecutingCount ?? "N/A"))
                                // MARK: 寫入UI
                                
                                ScheduleDevices.append(d)
                                
                            }
                            
                            isLoaded = true
                        }
                    }
                    
                    print("GET cloud-remote psas")
                }
                else if(code == 4002){
                    //back to login
                    print("Back to login view,error code = ", code)
                    DispatchQueue.main.async {
                        loginflag = true
                    }
                }
                else{
                    //back to login
                    print("Back to login view,error code = ", code)
                    DispatchQueue.main.async {
                        loginflag = true
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
    
    // MARK: - 管理用電-管理建議
    func GET_URLRequest_AdvMsg() async {

        let session = URLSession(configuration: .default)
        // 設定URL
        let user_id = CurrentUserID
        let url = PocUrl +  "api/nilm09/adv_msg?user_id=\(user_id)"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
                print("連線到伺服器 (GET adv_msg)")
//                print(response)
                
                // MARK: 解析json
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    //let code = json?["code"] as? Int
                    //let message = json?["message"] as? String
                    //print("code: \(code)")
                    //print("message: \(message)")
                    
                    let dataDict = json?["data"] as? [String: Any]
//                    let userId = dataDict?["user_id"] as? String
                    //print("data: \(dataDict)")

                    
                    if let msgArray = dataDict?["msg_info"] as? [[String: Any]]{
                        DispatchQueue.main.async {
                            ElectricityMsgArray = [ElectricityMsgInfo]()
                            
                            for msg in msgArray{
                                let sendtime = msg["send_time"] as? String
                                let advice = msg["advice"] as? String
                                let response = msg["response"] as? String
                                                                
                                //print(sendtime)
                                //print(advice)
                                //print(response)
                                
                                let data : ElectricityMsgInfo = ElectricityMsgInfo(sendTime: sendtime ?? "N/A", 
                                                                                   advice: advice ?? "N/A",
                                                                                   response: response ?? "N/A")
                                ElectricityMsgArray.append(data)
                                
                                // MARK: 只要偵測到有一個為空 就顯示紅點
                                if(response == nil){
                                    self.showWarningIcon = true
                                }
                            }
                        }
                    }
                
                    print("GET adv_msg Pass")
                } catch {
                    print(error)
                }
        }
        task.resume()
        
    }
    
    // MARK: -拿取通知項目數
    func GET_URLRequest_Forapp() async {
        let session = URLSession(configuration: .default)
        let user_id = CurrentUserID
        // 設定URL
//        let url = PocUrl +  "forapp?user_id=\(user_id)"
        let url = PocUrl +  "api/nilm09/forapp?user_id=\(user_id)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET Forapp)")
//            print(response)
//            print(data)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                let code = json?["code"] as? Int
//                let message = json?["message"] as? String
                //print("code: \(code)")
                //print("message: \(message)")
                
                let dataDict = json?["app"] as? [String: Any]
                //let userId = dataDict?["user_id"] as? String
                let user_advice_bt = dataDict?["user_advice_bt"] as? String
                let weekly_monthly_report_bth = dataDict?["weekly_monthly_report_bth"] as? String
                let manage_control_advice_bth = dataDict?["manage_control_advice_bth"] as? String
                //print("user_id: \(userId)")
                //print("user_advice_bt: \(user_advice_bt)")
                //print("weekly_monthly_report_bth: \(weekly_monthly_report_bth)")
                //print("manage_control_advice_bth: \(manage_control_advice_bth)")
                DispatchQueue.main.async {
                    self.forapp.User_advice_bt = Int(user_advice_bt!) ?? 0
                    self.forapp.Weekly_monthly_report_bth = Int(weekly_monthly_report_bth!) ?? 0
                    self.forapp.Manage_control_advice_bth = Int(manage_control_advice_bth!) ?? 0
                }
                print("GET Forapp Pass")
            } catch {
                print(error)
                }
        }
        task.resume()
    }
}

class ProgressManager : ObservableObject {
    @Published var inProgress = false
}

class Electricity_MsgManager : ObservableObject {
    @Published var showAlert = false
    @Published var ElectricityMsg = [ElectricityMsgInfo]()
}

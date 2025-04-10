//
//  ElectricityTrackingView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/3/6.
//

import SwiftUI

struct ElectricityTrackingView: View {
    
    @Binding var loginflag:Bool
    @Binding var robotIconDisplay:Bool
    @Binding var forapp:Forapp
    @ObservedObject var socketManager : AppSocketManager
    
    @EnvironmentObject var electricityElectricityTrackingAlertManager : ElectricityTrackingAlertManager
    @EnvironmentObject var electricityModifyElectricityTargetAlertManager : ModifyElectricityTargetAlertManager
    @EnvironmentObject var electricityGraphicsAlertManager : GraphicsAlertManager
    
    @State var beyesterdayData : BeyesterdayDataStruct = BeyesterdayDataStruct()
    @State var isLoaded = false
//    @State var showWarningAlert : Bool = false
//    @State var currentApplianceData = ApplianceDataStruct()
    
    @State var lastAccumDollars : Float = 0
    
    @State var daily_abnormal: Bool = false
    //昨日用電比例
    @State var yesterdayRatio : Float = 0
    //前天用電比例
    @State var before_yesterdayRatio : Float = 0
    //累積電量比例
    @State var targetRatio : Float = 0

    //與去年比較
    @State var previous_year_date : Int = 0
//    @State var loginday : Int = 0
//    @State var showContinuousLoginAlert: Bool = false
    
//    @State var performance : String = ""
//    @State var weekly_advice : String = ""
//    @State var showWeekly_MsgAlert: Bool = false
    
    let calendar = Calendar.current
    let currentDate = Date()
    
    @State var isLoginapp = false
    @State var isWeekly_msg = false
    
    var body: some View {
        ZStack{
            BackgroundColor.ignoresSafeArea(.all, edges: .top)
            
            VStack (){
                VStack{
                    Image("top-title").resizable().scaledToFit()
                        .foregroundColor(.clear)
                        .frame(width: 177.0, height: 27)                                    
                }.frame(height: 50.0)
                                                
                ScrollView{                    
                    Group {
                        HStack(alignment: .bottom){
                            Text("用電追蹤").font(.custom("NotoSansTC-Bold", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(NavyBlueCustomizeColor)
                            
                            
                            Text((self.isLoaded ? (beyesterdayData.report_time ?? "0000-00-00 ") : "0000-00-00 ") + "更新")
                                .font(.custom("NotoSansTC-Medium", size: 16))
                                .foregroundColor(Color(red: 145.0 / 255.0, green: 147.0 / 255.0, blue: 178.0 / 255.0))
                                .padding(.leading, 7)
                            
                            Spacer()
                        }
                    }.padding(.horizontal, 12).padding(.top, 15)
                                        
                    Group{
                        VStack{
                            Text("設定目標").font(.custom("NotoSansTC-Bold", size: 24))
                                .foregroundColor(Color(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 1.0))
                            ZStack{
                                Text(String(format: "%.0f", electricityModifyElectricityTargetAlertManager.totalTarget)).font(.custom("NotoSansTC-Bold", size: 50))
                                + Text(" 度").font(.custom("NotoSansTC-Medium", size: 26))
                            }.foregroundColor(Color(red: 57.0 / 255.0, green: 60.0 / 255.0, blue: 109.0 / 255.0))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80.0, maxHeight: 80.0)
                                .background(Color(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 1.0))
                                .cornerRadius(40.0)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        
                                        ZStack{
                                            
                                            Circle()
                                                .foregroundColor(Color(red: 242.0 / 255.0, green: 243.0 / 255.0, blue: 251.0 / 255.0))
                                            
                                            Button {
                                                //print("按下設定目標")
                                                
                                                print("按下設定目標")
                                                electricityModifyElectricityTargetAlertManager.showAlert = true
                                                
                                            } label: {
                                                Image("pencil")
                                                    .resizable()//.scaledToFit()
                                                    .frame(width: 30.0, height: 30.0)
                                                    .foregroundColor(.clear)
                                                
                                            }
                                        }.frame(width: 50.0, height: 50.0)
                                            .padding(.trailing, 20)
                                    }
                                )
                                .padding(.horizontal, 25)
                            
                            Text("．不含社區公共電費．").font(.custom("NotoSansTC-Medium", size: 20))
                                .foregroundColor(Color(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 1.0))
                                .padding(.top, 25)
                                .padding(.bottom, 32)
                            
                            Spacer()
                        }.padding(.top, 28)
                        
                    }.frame(height: 250.0)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .background(Color(red: 93.0 / 255.0, green: 194.0 / 255.0, blue: 184.0 / 255.0))
                        .cornerRadius(10)
                        .padding(.horizontal, 12).padding(.top, 10)
                        .shadow(color: Color(white: 0.0, opacity: 0.3), radius: 3.0, x: 0.0, y: 0.0)
                    
                    Group {
                        ZStack(alignment: .top){
                            HStack {
                                ZStack{
                                    Circle()
                                        .foregroundColor(daily_abnormal ?
                                                         Color(red: 1.0, green: 96.0 / 255.0, blue: 96.0 / 255.0, opacity: 0.5):
                                                            Color(red: 104.0 / 255.0, green: 201.0 / 255.0, blue: 192.0 / 255.0))
                                        .frame(width: 40.0, height: 40.0)
                                    Circle()
                                        .foregroundColor(daily_abnormal ?
                                                         Color(red: 1.0, green: 96.0 / 255.0, blue: 96.0 / 255.0) :
                                                            Color(red: 44.0 / 255.0, green: 180.0 / 255.0, blue: 179.0 / 255.0))
                                        .frame(width: 30.0, height: 30.0)
                                    
                                    Button {
                                        print("按下鈴鐺標誌")
//                                        showGraphicsAlert = true
                                        electricityGraphicsAlertManager.showAlert = true
                                    } label: {
                                        Image("bell").resizable()//.scaledToFit()
                                            .frame(width: 20.0, height: 20.0)
                                    }
                                }.frame(width: 40.0, height: 40.0)
                                    .padding(.leading, 13).padding(.top, 10)
                                
                                Spacer()
                            }
                            
                            VStack{
                                
                                CustomCircularProgressView(viewSize: CGSize(width: 300, height: 300), progressText: Double(electricityModifyElectricityTargetAlertManager.mouthKwh), progress: Double(electricityModifyElectricityTargetAlertManager.useTargetRatio), previous_year_date: previous_year_date)
//                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .frame(width:300, height: 300)
                                
                                Group
                                {
                                    VStack (spacing: 0){
                                        HStack{
                                            Text("昨天用電量")
                                            Spacer()
                                            Text(self.isLoaded ? String(beyesterdayData.yesterday ?? 0) : "0") + Text(" 度")
                                        }
                                        CustomProgressView(progress: Double(self.yesterdayRatio) * 100, progressColor: Color.init(hex: "#20a2a0", alpha: 1.0))
                                            .padding(.top, 8)
                                    }.padding(.top, 25)
                                    
                                    VStack (spacing: 0){
                                        HStack{
                                            Text("前天用電量")
                                            Spacer()
                                            Text(self.isLoaded ? String(beyesterdayData.before_yesterday ?? 0) : "0") + Text(" 度")
                                        }
                                        CustomProgressView(progress: Double(self.before_yesterdayRatio) * 100, progressColor: Color.init(hex: "#20a2a0", alpha: 1.0))
                                            .padding(.top, 8)
                                    }.padding(.top, 25)
                                    
                                    VStack (spacing: 0){
                                        HStack{
                                            Text("本月累積")
                                            Spacer()                                            
                                            Text("\(electricityModifyElectricityTargetAlertManager.mouthKwh, specifier: "%.0f")") + Text(" 度")
                                        }
                                        CustomProgressView(progress: Double(electricityModifyElectricityTargetAlertManager.useTargetRatio) * 100, progressColor: Color.init(hex: "#20a2a0", alpha: 1.0))
                                            .padding(.top, 8)
                                    }.padding(.top, 25)
                                    
                                }.font(.custom("NotoSansTC-Medium", size: 20))
                                    .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                                
                            }.padding(.top, 34).padding(.horizontal, 24).padding(.bottom, 36)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 1.0))
                    .cornerRadius(10)
                    //                .padding([.leading, .trailing, .bottom, .top])
                    .padding(.horizontal, 12).padding(.top, 10)
                    .shadow(color: Color(white: 0.0, opacity: 0.3), radius: 3.0, x: 0.0, y: 0.0)
                    Group {
                        VStack{
                            Text("本月家庭用電流向")
                                .font(.custom("NotoSansTC-Bold", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(Color.init(hex: "#464842", alpha: 1.0))
                                .padding(.top)
                                .padding()
                            
                            if(self.isLoaded)
                            {
                                ForEach(0..<TotalApplianceData.count, id: \.self){  index in
                                    ApplianceUIView(showAlert: $electricityElectricityTrackingAlertManager.showWarningCustomAlert, currentData: $electricityElectricityTrackingAlertManager.currentData, applianceData: TotalApplianceData[index]).padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
                                }
                            }
                        }.padding(.bottom)
                    }
                    Spacer()
                }
                Spacer()
            }
            
            if(!self.isLoaded){
                
                Color.init(hex: "#f3f3f3", alpha: 0.4)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
                    .scaleEffect(2)
            }
            
            // MARK: - 警告視窗
//            if(showWarningAlert){
//                withAnimation {
//                    WarningCustomAlert(showAlert: $showWarningAlert, currentData: $currentApplianceData, forapp: $forapp)
//                }
//            }

//            // MARK: - 每週提示視窗
//            if(!showContinuousLoginAlert && showWeekly_MsgAlert)
//            {
//                withAnimation {
//                    Weekly_MsgAlert(showAlert: $showWeekly_MsgAlert, performance: performance, weekly_advice: weekly_advice)
//                }
//            }
//            // MARK: - 每日登入提示視窗
//            if(showContinuousLoginAlert)
//            {
//                withAnimation {
//                    ContinuousLoginAlert(showAlert: $showContinuousLoginAlert, loginday: loginday)
//                }
//            }

        }
        .onAppear{
            
            print("進入用電追蹤頁面")
            self.isLoaded = false
            
            if let value = UserDefaults.standard.string(forKey: "user_id") {
                CurrentUserID = value
            } else {
                print("User id UserDefaults is null. Current User ID  = ", CurrentUserID)
            }
            
            // MARK: 啟用Socket
            if(socketManager.isConnected != true)
            {
                socketManager.setupSocket()
            }
            // MARK: 機器人圖示為開啟
            self.robotIconDisplay = true
                        
                        
            // MARK: 取得App通知勳章的參數
            Task{
                await GET_URLRequest_Forapp()
            }
            
            // MARK: 傳送apn device token
            Task{
                await POST_URLRequest_ios_user_token()
            }
            
            // MARK: 取得連續登入天數
            Task{
                if (!isLoginapp){
                    await GET_URLRequest_Loginapp()
                }
            }
            
            // MARK: 取得週報參數
            Task{
                if (!isWeekly_msg)
                {
                    await GET_URLRequest_weekly_msg(getLastMonday())
                }
            }
            
            // MARK: 取得鈴鐺通知參數
            Task{
                await GET_URLRequest_Ttl_war()
            }
            
            // MARK: 休眠N秒 等待token完全寫入才能使用
//            Thread.sleep(forTimeInterval: 1)
            
            // MARK: 取得累積用電量與設定累積電量
            Task{
                await GET_URLRequest_Current_Mon()
            }
                        
//            Thread.sleep(forTimeInterval: 1)
            
            //MARK: 取得昨日用電量與前天用電量
            Task{
                await GET_URLRequest_Beyesterday()
            }
            
            // MARK: 取得個電器資訊
            Task{
                await GET_URLRequest_Appliance2()
            }
        }
    }
    
    // MARK: - 取得 顯示昨天、前天、去年的今天用電量
    func GET_URLRequest_Beyesterday() async {
        //new API use beyesterday
        
        let session = URLSession(configuration: .default)
        // 設定URL
        let user_id = CurrentUserID
        let url = PocUrl +  "api/nilm09/beyesterday?user_id=\(user_id)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET Beyesterday)")
            //print(response)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                //let code = json?["code"] as? Int
                //let message = json?["message"] as? String
                //print("code: \(code)")
                //print("message: \(message)")
                
                let dataDict = json?["data"] as? [String: Any]
                let userId = dataDict?["user_id"] as? String
                let reportTime = dataDict?["report_time"] as? String
                let yesterday = dataDict?["yesterday"] as? Int
                let beforeYesterday = dataDict?["before_yesterday"] as? Int
                // MARK: 新增去年比較
                let previousYearDate = dataDict?["previous_year_date"] as? Int
                //print("user_id: \(userId)")
                //print("report_time: \(reportTime)")
                //print("yesterday(昨日用電量): \(yesterday)")
                //print("before_yesterday(前天用電量): \(beforeYesterday)")
                //print("previousYearDate = \(previousYearDate)")
                
                DispatchQueue.main.async {
                    beyesterdayData.user_id = userId
                    
                    //取年月日
                    let reportTimeComponents = reportTime?.components(separatedBy: " ")
                    beyesterdayData.report_time = reportTimeComponents?[0]
                    //昨天用電量
                    beyesterdayData.yesterday = yesterday
                    //print("目前累積用電: \(electricityModifyElectricityTargetAlertManager.mouthKwh)")
                    //計算昨日用電比例
                    self.yesterdayRatio = Float(yesterday ?? 0) / electricityModifyElectricityTargetAlertManager.mouthKwh
                    //print("yesterdayRatio(昨日用電量比例): \(self.yesterdayRatio)")
                    //前天用電量
                    beyesterdayData.before_yesterday = beforeYesterday
                    //計算前天用電比例
                    self.before_yesterdayRatio = Float(beforeYesterday ?? 0) / electricityModifyElectricityTargetAlertManager.mouthKwh
                    //print("before_yesterdayRatio(前天用電量比例): \(self.before_yesterdayRatio)")
                    //將去年用電比較帶回全域
                    self.previous_year_date = previousYearDate ?? -9999
                }
                print("GET Beyesterday Pass")
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
    
    
    // MARK: - 用電追蹤-用電趨勢(新版api) (用電趨勢鈴鐺顏色)
    func GET_URLRequest_Ttl_war() async {
        let session = URLSession(configuration: .default)
        let user_id = CurrentUserID
        // 設定URL
//        let url = PocUrl +  "forapp?user_id=\(user_id)"
        let url = PocUrl +  "api/nilm09/ttl_war?user_id=\(user_id)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET Ttl_war)")
            //print(response)
            //print(data)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                //let code = json?["code"] as? Int
                //let message = json?["message"] as? String
                //print("code: \(code)")
                //print("message: \(message)")
                
                let dataDict = json?["daily_abnormal"] as? [String: Any]
                let data = dataDict?["data"] as? String
                //                    print(data)
                DispatchQueue.main.async {
                    if (data == ""){
                        //綠色鈴鐺
                        daily_abnormal = false
                    }else
                    {
                        //紅色鈴鐺
                        daily_abnormal = true
                    }
                }
                
                print("GET Ttl_war Pass")
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    // MARK: -取得本月用電目標(本月累積相關內容)
    func GET_URLRequest_Current_Mon() async {
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let url = PocUrl + "api/main/trace/current-mon"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET current-mon)")
            //print(response)
            //print(data)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //let message = json?["message"] as? String
                //print("code: \(code)")
                //print("message: \(message)")
                
                //print("GET_URLRequest_Current_Mon get token : ", token)
                
                if(code == 200){
                    let dataDict = json?["data"] as? [String: Any]
                    //用電評論
                    //let predResult = dataDict?["predResult"] as? String
                    //本月設定用電目標
                    let target = dataDict?["target"] as? Int
                    //本月累積電量
                    let accumKwh = dataDict?["accumKwh"] as? Float
                    //print("target(本月設定用電目標): \(target)")
                    //print("accumKwh(本月累積電量): \(accumKwh)")
                    
                    DispatchQueue.main.async {
                        //本月設定用電目標
                        electricityModifyElectricityTargetAlertManager.totalTarget = Float(target ?? 0).rounded()
                        //本月累積電量
                        electricityModifyElectricityTargetAlertManager.mouthKwh = accumKwh ?? 1
                        //計算累積用電與預期目標比例
                        electricityModifyElectricityTargetAlertManager.useTargetRatio = electricityModifyElectricityTargetAlertManager.mouthKwh / (electricityModifyElectricityTargetAlertManager.totalTarget * 1.2)
                        
                        if(electricityModifyElectricityTargetAlertManager.useTargetRatio > 1){
                            electricityModifyElectricityTargetAlertManager.useTargetRatio = 1
                        }
                    }
                    print("GET current-mon pass")
                    
                }
                else if(code == 4002){
                    //back to login
                    print("Back to login view,error code = ", code)
                    DispatchQueue.main.async {
                        loginflag = true
                    }
                }
                else{
                    DispatchQueue.main.async {
                        electricityModifyElectricityTargetAlertManager.totalTarget = 100
                    }
                    //                        self.lastAccumDollars = 0
                    //                        self.targetRatio = 0
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
     
    // MARK: -取得用電流向 (取得各電器用量) *舊版
    func GET_URLRequest_Appliance() async{
     
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let url = PocUrl + "api/main/trace/appliance"
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 3 // seconds
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET Appliance)")
            //                print(response)
            //                print(data)
            
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoaded = true
                }
            }
            if let error = error as? URLError, error.code == .timedOut {
                print("Request timed out")
                DispatchQueue.main.async {
                    isLoaded = true
                }
            }
            
            // MARK: 解析json
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                if let _data = json["data"] as? [String: Any], let _result = _data["result"] as? [[String: Any]] {
                    
                    //清除陣列
                    otherApplianceData = [ApplianceDataStruct]()
                    
                    // 逐個讀取result陣列中的元素
                    for item in _result {
                        var d : ApplianceDataStruct = ApplianceDataStruct()
                        d.advice = item["advice"]
                        d.advice2 = item["advice2"]
                        d.altered = item["altered"] as? Int
                        d.attention = item["attention"]
                        d.cnName = item["cnName"] as? String
                        d.name = item["name"] as? String
                        d.value = item["value"] as? Int
                        d.warning = item["warning"]
                        
                        //print("other name: \(d.name), cnName: \(d.cnName), value: \(d.value), warning: \(d.warning)")
                        //print("advice: \(d.advice), advice2: \(d.advice2), altered: \(d.altered), attention: \(d.attention)")
                        
                        //寫入陣列
                        otherApplianceData.append(d)
                    }
                    
                    // MARK: 搜尋並寫入全部陣列
                    //先清除舊的
                    TotalApplianceData = [ApplianceDataStruct]()
                    for (index, item) in ApplianceData.enumerated(){
                        
                        //宣告一個空的
                        var d : ApplianceDataStruct = ApplianceDataStruct()
                        var comp = false
                        for j in otherApplianceData{
                            //若找到名稱對應的設備則寫入資料
                            if (item == j.name) {
                                d.advice = j.advice
                                d.advice2 = j.advice2
                                d.altered = j.altered
                                d.attention = j.attention
                                d.cnName = j.cnName
                                d.name = j.name
                                d.value = j.value
                                d.warning = j.warning
                                
                                comp = true
                                break
                            }
                        }
                        
                        // 若沒找到相應名稱則依序將名稱寫入
                        if(!comp) {
                            d.name = item
                            d.cnName = ApplianceDataCn[index]
                        }
                        TotalApplianceData.append(d)
                    }
                    DispatchQueue.main.async {
                        isLoaded = true
                    }
                    print("GET Appliance pass")
                }
            }
        }
        task.resume()
    }
    
    // MARK: -取得用電流向 (取得各電器用量)
    func GET_URLRequest_Appliance2() async {
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        
        // 第一個URL
        let firstURL = PocUrl + "/api/nilm09/main/trace/appliance2"
        // 第二個URL
        let secondURL = PocUrl + "/api/main/trace/appliance2"
        
        // 創建第一個URLRequest
        var firstRequest = URLRequest(url: URL(string: firstURL)!)
        firstRequest.timeoutInterval = 3 // 設置超時時間
                
        firstRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        firstRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        firstRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        firstRequest.httpMethod = "GET"
        
        // 發送第一個URL請求
        let firstTask = session.dataTask(with: firstRequest) { (data, response, error) in
            print("連線到伺服器 (GET Appliance2)")
//            print(response)
            // 檢查第一個URL請求的結果
            if let error = error {
                print("First request error: \(error.localizedDescription)")
                // 如果第一個URL請求失敗，則嘗試發送第二個URL請求
                DispatchQueue.main.async {
                    makeSecondRequest(session: session, secondURL: secondURL)
                }
                return
            }
            
            // 檢查第一個URL請求的響應
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("First request server error")
                // 如果第一個URL請求失敗，則嘗試發送第二個URL請求
                DispatchQueue.main.async {
                    makeSecondRequest(session: session, secondURL: secondURL)
                }
                return
            }
            
            // 檢查第一個URL請求的數據
            guard let data = data else {
                print("First request data error")
                // 如果第一個URL請求失敗，則嘗試發送第二個URL請求
                DispatchQueue.main.async {
                    makeSecondRequest(session: session, secondURL: secondURL)
                }
                return
            }
            
            // 解析第一個URL請求的數據
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // 解析成功
                    // 處理第一個URL請求的響應數據
                    if let _data = json["data"] as? [String: Any], let _result = _data["result"] as? [[String: Any]] {
                        
                        //清除陣列
                        otherApplianceData = [ApplianceDataStruct]()
                        
                        // 逐個讀取result陣列中的元素
                        for item in _result {
                            var d : ApplianceDataStruct = ApplianceDataStruct()
                            d.advice = item["advice"]
                            d.advice2 = item["advice2"]
                            d.altered = item["altered"] as? Int
                            d.attention = item["attention"]
                            d.cnName = item["cnName"] as? String
                            d.name = item["name"] as? String
                            d.value = item["value"] as? Int
                            d.warning = item["warning"]
                            
//                            print("other name: \(d.name), cnName: \(d.cnName), value: \(d.value), warning: \(d.warning)")
//                            print("advice: \(d.advice), advice2: \(d.advice2), altered: \(d.altered), attention: \(d.attention)")
                            
                            //寫入陣列
                            otherApplianceData.append(d)
                        }
                        
                        // MARK: 搜尋並寫入全部陣列
                        //先清除舊的
                        TotalApplianceData = [ApplianceDataStruct]()
                        for (index, item) in ApplianceData.enumerated(){
                            
                            //宣告一個空的
                            var d : ApplianceDataStruct = ApplianceDataStruct()
                            var comp = false
                            for j in otherApplianceData{
                                //若找到名稱對應的設備則寫入資料
                                if (item == j.name) {
                                    d.advice = j.advice
                                    d.advice2 = j.advice2
                                    d.altered = j.altered
                                    d.attention = j.attention
                                    d.cnName = j.cnName
                                    d.name = j.name
                                    d.value = j.value
                                    d.warning = j.warning
                                    
                                    comp = true
                                    break
                                }
                            }
                            
                            // 若沒找到相應名稱則依序將名稱寫入
                            if(!comp) {
                                d.name = item
                                d.cnName = ApplianceDataCn[index]
                            }
                            TotalApplianceData.append(d)
                            //                                print("name: \(d.name), cnName: \(d.cnName)")
                        }
                        DispatchQueue.main.async {
                            isLoaded = true
                        }
                        print("GET Appliance2 pass (firstURL)")
                    }
                }
            } catch {
                print("First request JSON parse error: \(error)")
                // 如果第一個URL請求失敗，則嘗試發送第二個URL請求
                DispatchQueue.main.async {
                    makeSecondRequest(session: session, secondURL: secondURL)
                }
            }
        }
        
        // 發送第一個URL請求
        firstTask.resume()
    }

    // 發送第二個URL請求的函數
    func makeSecondRequest(session: URLSession, secondURL: String) {
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        var secondRequest = URLRequest(url: URL(string: secondURL)!)
        secondRequest.timeoutInterval = 3 // 設置超時時間
        secondRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        secondRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        secondRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        secondRequest.httpMethod = "GET"
        
        // 發送第二個URL請求
        let secondTask = session.dataTask(with: secondRequest) { (data, response, error) in
            print("連線到伺服器 (GET Appliance2)")
            // 處理第二個URL請求的結果...
            
            // 處理錯誤
            if let error = error {
                print("Second request error: \(error.localizedDescription)")
                isLoaded = true
                return
            }
            
            // 檢查第二個URL請求的響應
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Second request server error")
                isLoaded = true
                return
            }
            
            // 檢查第二個URL請求的數據
            guard let data = data else {
                print("Second request data error")
                isLoaded = true
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let _data = json["data"] as? [String: Any], let _result = _data["result"] as? [[String: Any]] {
                    
                    //清除陣列
                    otherApplianceData = [ApplianceDataStruct]()
                    
                    // 逐個讀取result陣列中的元素
                    for item in _result {
                        
                        var d : ApplianceDataStruct = ApplianceDataStruct()
                        d.advice = item["advice"]
                        d.advice2 = item["advice2"]
                        d.altered = item["altered"] as? Int
                        d.attention = item["attention"]
                        d.cnName = item["cnName"] as? String
                        d.name = item["name"] as? String
                        d.value = item["value"] as? Int
                        d.warning = item["warning"]
                        
                        //print("other name: \(d.name), cnName: \(d.cnName), value: \(d.value), warning: \(d.warning)")
                        //print("advice: \(d.advice), advice2: \(d.advice2), altered: \(d.altered), attention: \(d.attention)")
                        
                        //寫入陣列
                        otherApplianceData.append(d)
                    }
                    
                    // MARK: 搜尋並寫入全部陣列
                    //先清除舊的
                    TotalApplianceData = [ApplianceDataStruct]()
                    for (index, item) in ApplianceData.enumerated(){
                        
                        //宣告一個空的
                        var d : ApplianceDataStruct = ApplianceDataStruct()
                        var comp = false
                        for j in otherApplianceData{
                            //若找到名稱對應的設備則寫入資料
                            if (item == j.name) {
                                d.advice = j.advice
                                d.advice2 = j.advice2
                                d.altered = j.altered
                                d.attention = j.attention
                                d.cnName = j.cnName
                                d.name = j.name
                                d.value = j.value
                                d.warning = j.warning
                                
                                comp = true
                                break
                            }
                        }
                        
                        // 若沒找到相應名稱則依序將名稱寫入
                        if(!comp) {
                            d.name = item
                            d.cnName = ApplianceDataCn[index]
                        }
                        TotalApplianceData.append(d)
                        //print("name: \(d.name), cnName: \(d.cnName)")
                    }
                                        
                    isLoaded = true
                    print("GET Appliance2 pass (secondURL)")
                    
                }
            }
        }
        // 發送第二個URL請求
        secondTask.resume()
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
            //                print(response)
            //                print(data)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                //let code = json?["code"] as? Int
                //let message = json?["message"] as? String
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
                    forapp.User_advice_bt = Int(user_advice_bt!) ?? 0
                    forapp.Weekly_monthly_report_bth = Int(weekly_monthly_report_bth!) ?? 0
                    forapp.Manage_control_advice_bth = Int(manage_control_advice_bth!) ?? 0
                }
                //testNumber
                //forapp.User_advice_bt = 1
                print("GET Forapp Pass")
            } catch {
                print(error)
                }
        }
        task.resume()
    }
    
    // MARK: -拿取連續登入天數
    func GET_URLRequest_Loginapp() async{
        let session = URLSession(configuration: .default)
        let user_id = CurrentUserID
        // 設定URL
//        let url = PocUrl +  "loginapp?user_id=\(user_id)"
        let url = PocUrl +  "api/nilm09/loginapp?user_id=\(user_id)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET Loginapp)")
            //                print(response)
            //                print(data)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let dataDict = json?["app"] as? [String: Any]
                //                    let userId = dataDict?["user_id"] as? String
                DispatchQueue.main.async {
                    electricityElectricityTrackingAlertManager.loginday = dataDict?["loginday"] as? Int ?? 0
                    let check = dataDict?["check"] as? String
                    
                    if(check == "0" && electricityElectricityTrackingAlertManager.loginday > 1){
//                        showContinuousLoginAlert = true
                        electricityElectricityTrackingAlertManager.showContinuousLoginAlert = true
                        print("連續登入天數：\(electricityElectricityTrackingAlertManager.loginday)")
                    }
                    else if (check == "1" && electricityElectricityTrackingAlertManager.loginday > 1){
                        print("連續登入天數(已看過)：\(electricityElectricityTrackingAlertManager.loginday)")
                    }
                    else{
                        print("不符合連續登入條件：天數 = \(electricityElectricityTrackingAlertManager.loginday) , 確認 = \(String(describing: check))")
                    }
                    
                    self.isLoginapp = true
                }
                print("GET Loginapp Pass")
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    // MARK: -首頁週報
    func GET_URLRequest_weekly_msg(_ startDate : String) async{
     
        let session = URLSession(configuration: .default)
        let user_id = CurrentUserID
        // 設定URL
//        let url = PocUrl +  "weekly_msg?user_id=\(user_id)&start_date=\(startDate)"
        let url = PocUrl +  "api/nilm09/weekly_msg?user_id=\(user_id)&start_date=\(startDate)"
        var request = URLRequest(url: URL(string: url)!)
        
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "GET"

        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
                print("連線到伺服器 (GET weekly_msg)")
//                print(response)
//                print(data)
                
                // MARK: 解析json
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                    print(json)
//                    let code = json?["code"] as? Int
//                    let message = json?["message"] as? String
//                    print("code: \(code)")
//                    print("message: \(message)")
                    DispatchQueue.main.async {
                        let dataDict = json?["data"] as? [String: Any]
//                        performance = dataDict?["performance"] as! String
//                        weekly_advice = dataDict?["weekly_advice"] as! String
                        electricityElectricityTrackingAlertManager.performance = dataDict?["performance"] as! String
                        electricityElectricityTrackingAlertManager.weekly_advice = dataDict?["weekly_advice"] as! String
                        
                        let response = dataDict?["response"] as? String
                        //                    print("performance: \(performance)")
                        //                    print("weekly_advice: \(weekly_advice)")
                        //                    print("response: \(response)")
                        
                        //為0或1時代表用戶已點選選項
                        if(response == "1" || response == "0"){
                            //                        showWeekly_MsgAlert = true
                        }
                        else{
                            electricityElectricityTrackingAlertManager.showWeekly_MsgAlert = true
                        }
                        
                        isWeekly_msg = true
                    }
                    print("GET weekly_msg Pass")
                } catch {
                    print(error)
                }
        }
        task.resume()
    }
    
    // MARK: 傳送現在的device token
    func POST_URLRequest_ios_user_token() async{
        
        let session = URLSession(configuration: .default)
        // 設定URL
//        let url = PocUrl + "api/nilm09/ios/user/token"
//        let url = "http://54.65.71.9:5000/ios/user/token"
        let url = ChatAIUrl + "ios/user/token"
    
    
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let user_id = CurrentUserID
        let device_token = DeviceToken
        let update_time = getCurrentDateTime()
        let postData = ["user_id":user_id,"app_token":device_token,"update_time":update_time]
        print("postData -> \(postData)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
            request.httpBody = jsonData
        } catch {
            
        }
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            do {
                print("連線到伺服器 (POST ios_user_token)")
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                print(response)
//                print(json)                
                
                print("POST ios_user_token Pass")
            } catch {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    
    func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self.currentDate)
    }
    
    func getLastMonday() -> String {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday + 5) % 7  + 7
        var lastMonday = ""
        
        //取得上週一的日期
        if let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
//            let mondayString = formatter.string(from: monday)
//            print("星期一的日期是：\(mondayString)")
            lastMonday = formatter.string(from: monday)
        }
        return lastMonday
            
    }
    
    func areDatesSame(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let date1Components = calendar.dateComponents([.year, .month, .day], from: date1)
        let date2Components = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return date1Components.year == date2Components.year
            && date1Components.month == date2Components.month
            && date1Components.day == date2Components.day
    }
    
    func areDatesOneDayApart(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        
        // 比較兩個日期的年月日
        let date1Components = calendar.dateComponents([.year, .month, .day], from: date1)
        let date2Components = calendar.dateComponents([.year, .month, .day], from: date2)
        
        // 使用dateComponents(_:from:to:)計算兩個日期的差異
        let difference = calendar.dateComponents([.day], from: date1Components, to: date2Components)
        
        // 判斷是否為差一天
        return difference.day == 1
    }
    
    struct GettokenCodable: Codable{
        let user_id:String?
        let access_token:String?
    }
}


//
//  SchedulePageView.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/14.
//

import SwiftUI

struct SchedulePageView: View {

    @Binding var loginflag : Bool
    @Binding var showAlert: Bool
    @Binding var deviceId : String
//    @Binding var total_pages : Int
//    @Binding var current_page : Int
    @Binding var isDataEmpty : Bool
    @State var cloudRemoteSchedulesArray = [CloudRemoteSchedulesInfo]()
    @State var isLoaded = false
    @State private var isEnabled = [Bool]()
    @EnvironmentObject var createReviseScheduleManager : CreateReviseScheduleManager
    @EnvironmentObject var electricityCustomDeleteAlertManager : CustomDeleteAlertManager
    @EnvironmentObject var electricityCustomAlertManager : CustomAlertManager
        
    var body: some View {
        ZStack{
            if(cloudRemoteSchedulesArray.count > 0 && isLoaded) {
                ScrollView(.horizontal, showsIndicators: true)
                {
                    HStack (spacing: 0){
                        Text("狀態").frame(width: 73, height: 25, alignment: .leading).padding(.leading, 7)
                        Text("時間").frame(width: 85, height: 25)
                        Text("頻率").frame(width: 85, height: 25)
                        Text("週期").frame(width: 110, height: 25)
                        Text("動作").frame(width: 85, height: 25)
                        Text("").frame(width: 85, height: 25)
                        
                    }.font(.custom("NotoSansTC-Medium", size: 18))
                        .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                    
                    VStack (spacing: 3){
                        ScrollView (.vertical, showsIndicators: true){
                            ForEach(0..<cloudRemoteSchedulesArray.count, id: \.self){  index in
                                HStack (spacing: 0){
                                                                      
                                    Toggle("", isOn: $isEnabled[index]).toggleStyle(ScheduleToggleStyle()).frame(width: 80, height: 25)
                                        .onChange(of: isEnabled[index]){value in                                   
                                            if(self.isLoaded)
                                            {
                                                //print("Toggle : " + String(value))
                                                //MARK: 初始化修改排程內容
                                                createReviseScheduleManager.isCreateSchedule = false
                                                createReviseScheduleManager.deviceId = cloudRemoteSchedulesArray[index].dev_id ?? "N/A"
                                                createReviseScheduleManager.triggerName = cloudRemoteSchedulesArray[index].trigger_name ?? "N/A"
                                                createReviseScheduleManager.schedTime = cloudRemoteSchedulesArray[index].sched_time ?? "N/A"
                                                createReviseScheduleManager.currentSchedDate =
                                                convertToDate(from: cloudRemoteSchedulesArray[index].sched_time ?? "N/A")
                                                createReviseScheduleManager.schedFreq = cloudRemoteSchedulesArray[index].sched_freq ?? "N/A"
                                                createReviseScheduleManager.action = cloudRemoteSchedulesArray[index].action ?? "N/A"
                                                
                                                createReviseScheduleManager.enable = value ? "yes" : "no"
                                                                                               
                                                createReviseScheduleManager.weekOnOffArray =
                                                weekStringToBoolArray(cloudRemoteSchedulesArray[index].sched_week ?? "N/A")

                                                
                                                ReviseSchedule(createReviseScheduleManager.deviceId, createReviseScheduleManager.triggerName,
                                                               createReviseScheduleManager.action, createReviseScheduleManager.schedFreq,
                                                               createReviseScheduleManager.weekOnOffArray, createReviseScheduleManager.schedTime,
                                                               createReviseScheduleManager.enable)
                                            }
                                        }
                                    
                                    Text(cloudRemoteSchedulesArray[index].sched_time ?? "N/A").frame(width: 85, height: 25)
                                    Text(getFreqString(cloudRemoteSchedulesArray[index].sched_freq ?? "N/A")).frame(width: 85, height: 25)
                                    Text(getWeekString(cloudRemoteSchedulesArray[index].sched_freq ?? "N/A",
                                                       cloudRemoteSchedulesArray[index].sched_week ?? "N/A")).frame(width: 110, height: 25)
                                    Text(getActionString(cloudRemoteSchedulesArray[index].action ?? "N/A")).frame(width: 85, height: 25)
                                    
                                    HStack{
                                        Button {
                                            print("按下編輯圖示")
//                                            self.showAlert = false
                                            
                                            //MARK: 初始化修改排程內容
                                            createReviseScheduleManager.isCreateSchedule = false
                                            createReviseScheduleManager.deviceId = cloudRemoteSchedulesArray[index].dev_id ?? "N/A"
                                            createReviseScheduleManager.triggerName = cloudRemoteSchedulesArray[index].trigger_name ?? "N/A"
                                            createReviseScheduleManager.schedTime = cloudRemoteSchedulesArray[index].sched_time ?? "N/A"
                                            createReviseScheduleManager.currentSchedDate =
                                            convertToDate(from: cloudRemoteSchedulesArray[index].sched_time ?? "N/A")
                                            createReviseScheduleManager.schedFreq = cloudRemoteSchedulesArray[index].sched_freq ?? "N/A"
                                            createReviseScheduleManager.action = cloudRemoteSchedulesArray[index].action ?? "N/A"
                                            createReviseScheduleManager.enable = isEnabled[index] ? "yes" : "no"
                                            
                                            createReviseScheduleManager.weekOnOffArray =
                                            weekStringToBoolArray(cloudRemoteSchedulesArray[index].sched_week ?? "N/A")
                                            
//                                            print(createReviseScheduleManager.deviceId)
//                                            print(createReviseScheduleManager.schedTime)
//                                            print(createReviseScheduleManager.schedFreq)
//                                            print(createReviseScheduleManager.action)
//                                            print(createReviseScheduleManager.enable)
//                                            print(createReviseScheduleManager.weekOnOffArray)
//                                            print(cloudRemoteSchedulesArray[index].sched_week)
                                                                                    
                                            createReviseScheduleManager.showAlert = true
                                            
                                        } label: {
                                            Image("pencil").resizable()//.scaledToFit()
                                                .frame(width: 20.0, height: 20.0)
                                                .foregroundColor(.clear)
                                        }
                                        Button {
                                            print("按下刪除圖示")
                                            
//                                            DELETE_URLRequest_CloudRemote_Schedule_Delete(cloudRemoteSchedulesArray[index].trigger_name ?? "N/A")
                                            electricityCustomDeleteAlertManager.index = index
                                            electricityCustomDeleteAlertManager.isPresented = true
                                            
                                        } label: {
                                            Image("trash").resizable()//.scaledToFit()
                                                .frame(width: 20.0, height: 20.0)
                                                .foregroundColor(.clear)
                                        }.padding(.leading, 10)
                                        
                                    }.frame(width: 85, height: 25)
                                }
                                .font(.custom("NotoSansTC-Medium", size: 18))
                                .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                                .frame(height: 52).frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .padding(.top , 9)
                }.padding(.horizontal, 26).padding(.top , 33)
            }
            else if !self.isLoaded {
                VStack{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
                        .scaleEffect(2)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                .cornerRadius(5.0)
                .padding(.horizontal,25).padding(.top,33)
            }
            else{
                VStack{
                    Image("icon-schedule-no-data").resizable().scaledToFit().frame(width: 60.0, height: 60.0)
                    Text("暫無資料").font(.custom("NotoSansTC-Medium", size: 16.0))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(cloudRemoteSchedulesArray.count > 0 ? .clear : Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                .cornerRadius(5.0)
                .padding(.horizontal,25).padding(.top,33)
            }
        }
        .onAppear{
            print("開啟排程管理(SchedulePage)頁面")
            isLoaded = false
            GET_URLRequest_CloidRemote_Schedule(self.deviceId)
        }
//        .onChange(of: createReviseScheduleManager.showAlert){value in
//            if(!createReviseScheduleManager.showAlert && !createReviseScheduleManager.isCancel)
//            {
//                isLoaded = false
//                GET_URLRequest_CloidRemote_Schedule(self.deviceId)
//            }            
//        }
        .onChange(of: electricityCustomAlertManager.isPresented){value in
            
            if(!createReviseScheduleManager.showAlert )//&& !createReviseScheduleManager.isCancel)
            {
                if(!electricityCustomAlertManager.isPresented){
                    print("刷新排程管理列表(SchedulePage)頁面")
                    isLoaded = false
                    GET_URLRequest_CloidRemote_Schedule(self.deviceId)
                }
            }
        }
        
        .onChange(of: electricityCustomDeleteAlertManager.isChangeDeleteBool){value in
            self.isLoaded = false
            performDeleteAction()
        }
    }
    
    func refreshView(){
        print("刷新排程管理列表(SchedulePage)頁面")
        isLoaded = false
        GET_URLRequest_CloidRemote_Schedule(self.deviceId)
    }
    
    func performDeleteAction() {
        print("Delete action performed.")
        DELETE_URLRequest_CloudRemote_Schedule_Delete(cloudRemoteSchedulesArray[electricityCustomDeleteAlertManager.index].trigger_name ?? "N/A")
    }
    
    
    func getEnableBool(_ action : String) ->Bool {
        
        switch action {
        case "yes":
            return true
        case "no":
            return false
        default:
            return false
        }
    }
    
    func getFreqString(_ sched_freq : String) ->String {
        
        switch sched_freq {
        case "weekly":
            return "每週"
        case "once":
            return "單次"
        default:
            return "N/A"
        }
    }
    
    func getWeekString(_ sched_freq : String, _ sched_week : String) ->String {
        

        if getFreqString(sched_freq) == "單次"
        {
            
            return "無"
        }
        else{
            var out : String = ""
            let daysArray = sched_week.components(separatedBy: ",")
       
            for (index, day) in daysArray.enumerated() {
                
                if index == daysArray.count - 1 {
                    out += weekEnglishtoChatString(day)
                }
                else{
                    out += weekEnglishtoChatString(day)
                    out += "、"
                }
            }
            
            return out
        }
    }
    
    func weekEnglishtoChatString(_ str : String) ->String {
        switch str {
        case "SUN":
            return "日"
        case "MON":
            return "一"
        case "TUE":
            return "二"
        case "WED":
            return "三"
        case "THU":
            return "四"
        case "FRI":
            return "五"
        case "SAT":
            return "六"
        default:
            return "N/A"
        }
    }
    
    func weekStringToBoolArray(_ sched_week : String) ->[Bool] {
        
        let weekStringArray = sched_week.components(separatedBy: ",")
        let weekArrayEN = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        var weekBoolArray = [false, false, false, false, false, false, false]
        
        for value in weekStringArray {
            if let index = weekArrayEN.firstIndex(of: value) {
                weekBoolArray[index] = true
            }
        }
        
        return weekBoolArray
    }
    
    func getActionString(_ action : String) ->String {
        if action == "on"{
            return "開放"
        }
        else{
            return "關閉"
        }
    }
    
    func convertToDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: string) {
            return date
        } else {
            return Date()
        }
    }
    
    
    // MARK: - 管理用電-取得排程管理列表
    func GET_URLRequest_CloidRemote_Schedule(_ device_Id : String) {
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let url = PocUrl + "api/main/cloud-remote/schedule?deviceId=\(device_Id)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
                print("連線到伺服器 (GET cloud-remote schedule)")
//                print(response)
//                print(data)
                
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
//                let message = json?["message"] as? String
                //                    print("code: \(code)")
                //                    print("message: \(message)")
                let data = json?["data"] as? [String: Any]
                //                    print(data)
                let schedules_count = data?["schedules_count"] as? Int
                //                    print("schedules_count : " + String(schedules_count ?? -1))
                
                let data_err = data?["err"] as? [String: Any]
                let data_code = data_err?["code"] as? String
                //                    print("data_code = \(data_code)")
                
                if (schedules_count == -1 || data_code != "0") {
                    isDataEmpty = true
                    isLoaded = true
                }
                else {
                    if(code == 200){
                        // MARK: 取得排程管理列表內容
                        if let dataDict = json?["data"] as? [String: Any], let _result = dataDict["schedules"] as? [[String: Any]] {
                            //先清除舊的
                            cloudRemoteSchedulesArray = [CloudRemoteSchedulesInfo]()
                            self.isEnabled = [Bool]()
                            
                            for item in _result {
                                var d : CloudRemoteSchedulesInfo = CloudRemoteSchedulesInfo()
                                
                                d.trigger_name = item["trigger_name"] as? String
                                d.job_detail_name = item["job_detail_name"] as? String
                                d.dev_id = item["dev_id"] as? String
                                d.action = item["action"] as? String
                                d.sched_freq = item["sched_freq"] as? String
                                d.sched_date = item["sched_date"] as? String
                                d.sched_week = item["sched_week"] as? String
                                d.sched_time = item["sched_time"] as? String
                                d.sched_desc = item["sched_desc"] as? String
                                d.timezone = item["timezone"] as? String
                                d.last_updated = item["last_updated"] as? String
                                d.enable = item["enable"] as? String
                                
                                //                                    print("dev_id : " + (d.dev_id ?? "null"))
                                //                                    print("action : " + (d.action ?? "null"))
                                //                                    print("sched_time : " + (d.sched_time ?? "null"))
                                //                                    print("sched_freq : " + (d.sched_freq ?? "null"))
                                //                                    print("enable : " + (d.enable ?? "null"))
                                //                                    print("sched_week : " + (d.sched_week ?? "null"))
                                
                                // MARK: 寫入UI
                                cloudRemoteSchedulesArray.append(d)
                                self.isEnabled.append(getEnableBool(d.enable ?? "N/A"))
                            }
                            isDataEmpty = false
                            isLoaded = true
                        }
                        
                        print("GET cloud-remote schedule psas")
                    }
                    else {
                        //back to login
                        print("Back to login view,error code = ", code)
                        loginflag = true
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    // MARK: - 設定排程內容
    func ReviseSchedule(_ deviceId: String, _ triggerName: String,
                        _ action: String, _ schedFreq: String,
                        _ schedWeekArray: [Bool], _ schedTime: String,
                        _ enable : String){
        print("(Toggle) Start Revise Schedule")
                        
        var schedWeek : String = ""
        let weekArrayEN = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        //若schedFreq為week時需要轉換schedWeek
        for (index, value) in schedWeekArray.enumerated() {
            if (value){
                schedWeek += weekArrayEN[index]
                schedWeek += ","
            }
        }
        schedWeek = String(schedWeek.dropLast())
        
        //取schedDate
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current // 使用現在的時區
        let schedDate = dateFormatter.string(from: currentDate)
        
//        print(deviceId)
//        print(triggerName)
//        print(action)
//        print(schedFreq)
//        print(schedTime)
//        print(enable)
//        print(schedWeek)
//        print(schedWeekArray)
        
        PATCH_URLRequest_CloudRemote_Schedule_Revise(deviceId, triggerName, action, schedFreq, schedTime, schedDate, enable, schedWeek)
        
    }
    
    // MARK: - 修改排程內容
    func PATCH_URLRequest_CloudRemote_Schedule_Revise(_ deviceId : String, _ triggerName: String, _ action : String,
    _ schedFreq : String, _ schedTime : String, _ schedDate : String, _ enable : String, _ schedWeek : String) {

        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
//        let url = PocUrl + "/api/main/cloud-remote/schedule?deviceId=\(deviceId)&triggerName=\(triggerName)&action=\(action)&schedFreq=\(schedFreq)&schedTime=\(schedTime)&enable=\(enable)&schedWeek=\(schedWeek)"
        
        var url = ""
        
        if(schedFreq == "once"){
            url = PocUrl + "/api/main/cloud-remote/schedule?deviceId=\(deviceId)&triggerName=\(triggerName)&action=\(action)&schedFreq=\(schedFreq)&schedTime=\(schedTime)&enable=\(enable)&schedDate=\(schedDate)"
        }
        else{
            print("修改每週")
            url = PocUrl + "/api/main/cloud-remote/schedule?deviceId=\(deviceId)&triggerName=\(triggerName)&action=\(action)&schedFreq=\(schedFreq)&schedTime=\(schedTime)&enable=\(enable)&schedWeek=\(schedWeek)"
        }
            
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (PATCH cloud-remote schedule)")
            //                print(response)
            
            // MARK: 解析json
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code = json?["code"] as? Int
                let message = json?["message"] as? String
                
                //print("code: \(code)")
                //print("message: \(message)")
                
//                if code == 200 {
//                    //let data = json?["data"] as? String
//                    //print(data)
//                    
//                    Thread.sleep(forTimeInterval: 0.1)
//                    //                        self.isLoaded = true
//                    //直接刷新頁面
////                    refreshView()
//                    
//                    
//                    print("PATCH cloud-remote schedule pass (revise)")
//                }
//                else{
//                    Thread.sleep(forTimeInterval: 0.1)
//                    //                        self.isLoaded = true
//                    print("PATCH cloud-remote schedule fail (revise) message : \(String(describing: message))")
//                }
                
                if code == 200 {
                    //let data = json?["data"] as? String
                    //print(data)
                    
//                    Thread.sleep(forTimeInterval: 0.1)
                    //                        self.isLoaded = true
                    //直接刷新頁面
//                    refreshView()
                    
                    print("PATCH cloud-remote schedule pass (revise)")
                }
                else{
                    Thread.sleep(forTimeInterval: 0.1)
                    self.isLoaded = true
                    
                    DispatchQueue.main.async {
                        electricityCustomAlertManager.message = "修改失敗"
                        electricityCustomAlertManager.isPresented = true
                    }
                    print("PATCH cloud-remote schedule fail (revise) message : \(String(describing: message))")
                }
                
            } catch {
                Thread.sleep(forTimeInterval: 0.1)
                //                    self.isLoaded = true
                print(error)
            }
        }
        task.resume()
    }
    
    // MARK: - 刪除排程內容
    func DELETE_URLRequest_CloudRemote_Schedule_Delete(_ triggerName: String) {

        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let url = PocUrl + "/api/main/cloud-remote/schedule?triggerName=\(triggerName)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"

        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (DELETE cloud-remote schedule)")
            //                print(response)
            
            // MARK: 解析json
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code = json?["code"] as? Int
                let message = json?["message"] as? String
                
                //                    print("code: \(code)")
                //                    print("message: \(message)")
                
                if code == 200 {
//                    let data = json?["data"] as? String
                    //                        print(data)
                    Thread.sleep(forTimeInterval: 0.1)
                    //                        self.isLoaded = true
                    
                    DispatchQueue.main.async {
                        electricityCustomAlertManager.message = "已刪除"
                        electricityCustomAlertManager.isPresented = true
                    }
//                    //直接刷新頁面
//                    refreshView()
                    
                    print("DELETE cloud-remote schedule pass (delete)")
                }
                else{
                    Thread.sleep(forTimeInterval: 0.1)
                    DispatchQueue.main.async {
                        electricityCustomAlertManager.message = "刪除失敗"
                        electricityCustomAlertManager.isPresented = true
                    }
                    print("DELETE cloud-remote schedule fail (delete) message : \(String(describing: message))")
                }
                
            } catch {
                Thread.sleep(forTimeInterval: 0.1)
                //                    self.isLoaded = true
                
                DispatchQueue.main.async {
                    electricityCustomAlertManager.message = "刪除失敗"
                    electricityCustomAlertManager.isPresented = true
                }
                print(error)
            }
        }
        task.resume()
    }
}

//#Preview {
//    SchedulePageView()
//}

struct ScheduleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // Insert custom View code here.
        HStack {
            configuration.label
            ZStack{
                Capsule()
                .foregroundColor(configuration.isOn ? GreenCustomizeColor :
                                    Color(red: 201.0 / 255.0, green: 207.0 / 255.0, blue: 229.0 / 255.0))
                .frame(width: 45, height: 21, alignment: .center)
                .overlay(
                    Circle()
                        .scaleEffect(0.8)
                        .foregroundColor(configuration.isOn ? Color.white : Color.white)
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
//                        .animation(Animation.linear(duration: 0.1))
                        .animation(.linear(duration: 0.1), value: configuration.isOn)
                )
                .onTapGesture { configuration.isOn.toggle() }
            }
        }
    }
}

extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

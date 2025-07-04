//
//  ScheduleCreateReviseView.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/15.
//

import SwiftUI


extension View {
    
    func environmentCreateReviseScheduleView(loginflag: Binding<Bool>, showAlert: Binding <Bool>, isCreateSchedule: Binding <Bool>, currentTime: Binding<Date>) -> some View {
        self.modifier(environmentCreateReviseScheduleAlert(loginflag: loginflag, showAlert: showAlert, isCreateSchedule: isCreateSchedule, currentTime: currentTime)
        )
    }
}

struct environmentCreateReviseScheduleAlert : ViewModifier {
    
    @EnvironmentObject var electricityScheduleManager : ElectricityScheduleManager
    @EnvironmentObject var createReviseScheduleManager : CreateReviseScheduleManager
    @EnvironmentObject var electricityCustomAlertManager : CustomAlertManager
    
    @Binding var loginflag: Bool
    @Binding var showAlert: Bool
    @Binding var isCreateSchedule : Bool
    @Binding var currentTime : Date
    @State private var showingDatePicker = false
    @State var isLoaded = false
    @State var weekArray = ["日", "一", "二", "三", "四", "五", "六"]
    
    func body(content: Content) -> some View {
        
        ZStack { content
            if showAlert {
                withAnimation {
                    showCreateReviseScheduleAlert()
                }
            }
        }
    }
}

extension environmentCreateReviseScheduleAlert {
    
    func showCreateReviseScheduleAlert() -> some View  {
        ZStack{
            Color(.clear).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showAlert = false
                    electricityScheduleManager.showAlert = true
                }
            
            VStack (spacing: 0){
                ZStack{
                    Text(self.isCreateSchedule ? "新增排程" : "修改排程").font(.custom("NotoSansTC-Medium", size: 24))
                        .foregroundColor(DarkGrayCustomizeColor)
                        .padding(.top, 20)
                    HStack{
                        Spacer()
                        Button {
                            createReviseScheduleManager.showAlert = false
                            createReviseScheduleManager.isCancel = true
                            electricityScheduleManager.showAlert = true
                        } label: {
                            Image(systemName: "xmark").resizable().scaledToFit()
                                .frame(width: 17.0, height: 17.0)
                                .foregroundColor(Color(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0))
                        }
                    }.padding(.trailing, 25).padding(.top, 25)
                }
                GeometryReader { geometry in
                    ScrollView {
                        VStack{
                            Group{
                                VStack (spacing: 10){
                                    Text("排程時間").font(.custom("NotoSansTC-Medium", size: 20))
                                        .foregroundColor(DarkGrayCustomizeColor)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack{
                                        Button(action: {
                                            showingDatePicker.toggle()
                                        }) {
                                            Text("\(formattedDate(currentTime))")
                                                .font(.custom("NotoSansTC-Medium", size: 20))
                                                .foregroundColor(Color(white: 160.0 / 255.0))
                                                .opacity(0)
                                        }
                                        
                                    }
                                    .frame(height: 52.0).frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .cornerRadius(5.0)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5.0)
                                            .inset(by: 0.5)
                                            .stroke(Color(white: 204.0 / 255.0), lineWidth: 1.0)
                                    )
                                    .overlay {
                                        DatePicker("請選擇時間點", selection: $currentTime, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.compact) // 扁平風格，像一行文字
                                            .labelsHidden()
                                            .frame(height: 52.0)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                            .background(Color.white)
                                            .cornerRadius(5.0)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5.0)
                                                    .inset(by: 0.5)
                                                    .stroke(Color(white: 204.0 / 255.0), lineWidth: 1.0)
                                            )
                                    }
                                    
                                }
                            }
                            
                            Group{
                                VStack (spacing: 10){
                                    HStack{
                                        Text("頻率").font(.custom("NotoSansTC-Medium", size: 20))
                                            .foregroundColor(DarkGrayCustomizeColor)
                                        Text("*24小時內時間執行單次排程").font(.custom("NotoSansTC-Medium", size: 14))
                                            .foregroundColor(Color(red: 1.0, green: 85.0 / 255.0, blue: 85.0 / 255.0))
                                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    
                                    Button(action: {
//                                        print("Button once")
                                        withAnimation {
                                            createReviseScheduleManager.schedFreq = "once"
                                        }
                                    }, label: {
                                        Text("單次").font(.custom("NotoSansTC-Medium", size: 20))
                                            .foregroundColor(createReviseScheduleManager.schedFreq == "once" ?
                                                             Color(white: 1.0) : DarkGrayCustomizeColor)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: 50.0)
                                            .background(createReviseScheduleManager.schedFreq == "once" ?
                                                        GreenCustomizeColor : .clear)
                                            .cornerRadius(30.0)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30.0)
                                                    .inset(by: 1.0)
                                                    .stroke(createReviseScheduleManager.schedFreq == "once" ?
                                                        .clear : DarkGrayCustomizeColor, lineWidth: 2.0)
                                            )
                                    }).disabled(createReviseScheduleManager.schedFreq == "once")
                                    
                                    Button(action: {
//                                        print("Button weekly")
                                        withAnimation {
                                            createReviseScheduleManager.schedFreq = "weekly"
                                        }
                                    }, label: {
                                        Text("每週").font(.custom("NotoSansTC-Medium", size: 20))
                                            .foregroundColor(createReviseScheduleManager.schedFreq == "weekly" ?
                                                             Color(white: 1.0) : DarkGrayCustomizeColor)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: 50.0)
                                            .background(createReviseScheduleManager.schedFreq == "weekly" ?
                                                        GreenCustomizeColor : .clear)
                                            .cornerRadius(30.0)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30.0)
                                                    .inset(by: 1.0)
                                                    .stroke(createReviseScheduleManager.schedFreq == "weekly" ?
                                                        .clear : DarkGrayCustomizeColor, lineWidth: 2.0)
                                            )
                                    }).disabled(createReviseScheduleManager.schedFreq == "weekly")
                                    
                                    if createReviseScheduleManager.schedFreq == "weekly" {
                                        Group{
                                            VStack (spacing: 0){
                                                HStack{
                                                    Text("週期").font(.custom("NotoSansTC-Medium", size: 20))
                                                        .foregroundColor(DarkGrayCustomizeColor)
                                                    
                                                    if(!createReviseScheduleManager.weekOnOffArray.contains(true)){
                                                        Text("*至少需選擇一天").font(.custom("NotoSansTC-Medium", size: 14))
                                                            .foregroundColor(Color(red: 1.0, green: 85.0 / 255.0, blue: 85.0 / 255.0))
                                                    }
                                                }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                
                                                ForEach(0..<2){  line in
                                                    if line == 0
                                                    {
                                                        HStack (spacing: 10) {
                                                            //self.weekArray.count
                                                            ForEach(0..<5){  index in
                                                                
                                                                Button(action: {
                                                                    createReviseScheduleManager.weekOnOffArray[index] = !createReviseScheduleManager.weekOnOffArray[index]//
                                                                }, label: {
                                                                    Text(self.weekArray[index])
                                                                        .foregroundColor(createReviseScheduleManager.weekOnOffArray[index] ?
                                                                                         Color(white: 1.0) : DarkGrayCustomizeColor)
                                                                        .frame(width: 50.0, height: 50.0)
                                                                        .background(createReviseScheduleManager.weekOnOffArray[index] ?
                                                                                    GreenCustomizeColor :  Color(white: 1.0))
                                                                        .cornerRadius(30.0)
                                                                        .overlay(
                                                                            RoundedRectangle(cornerRadius: 30.0)
                                                                                .inset(by: 1.0)
                                                                                .stroke(createReviseScheduleManager.weekOnOffArray[index] ?
                                                                                    .clear : DarkGrayCustomizeColor, lineWidth: 2.0))
                                                                })
                                                            }
                                                        }
                                                        .font(.custom("NotoSansTC-Medium", size: 20))
                                                        .padding(.top, 14)
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    }
                                                    
                                                    else{
                                                        HStack (spacing: 10) {
                                                            //self.weekArray.count
                                                            ForEach(5..<7){  index in
                                                                
                                                                Button(action: {
                                                                    createReviseScheduleManager.weekOnOffArray[index] = !createReviseScheduleManager.weekOnOffArray[index]
                                                                }, label: {
                                                                    Text(self.weekArray[index])
                                                                        .foregroundColor(createReviseScheduleManager.weekOnOffArray[index] ? 
                                                                                         Color(white: 1.0) : DarkGrayCustomizeColor)
                                                                        .frame(width: 50.0, height: 50.0)
                                                                        .background(createReviseScheduleManager.weekOnOffArray[index] ?
                                                                                    GreenCustomizeColor :  Color(white: 1.0))
                                                                        .cornerRadius(30.0)
                                                                        .overlay(
                                                                            RoundedRectangle(cornerRadius: 30.0)
                                                                                .inset(by: 1.0)
                                                                                .stroke(createReviseScheduleManager.weekOnOffArray[index] ?
                                                                                    .clear : DarkGrayCustomizeColor, lineWidth: 2.0))
                                                                })
                                                            }
                                                        }
                                                        .font(.custom("NotoSansTC-Medium", size: 20))
                                                        .padding(.top, 14)
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    }
                                                }
                                            }.padding(.top, 24)
                                        }
                                    }
                                }.padding(.top, 24)
                            }
                            
                            Group{
                                VStack (spacing: 10){
                                    Text("動作").font(.custom("NotoSansTC-Medium", size: 20))
                                        .foregroundColor(DarkGrayCustomizeColor)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    
                                    Button(action: {
                                        createReviseScheduleManager.action = "on"
                                    }, label: {
                                        Text("啟用").font(.custom("NotoSansTC-Medium", size: 20))
                                            .foregroundColor(createReviseScheduleManager.action == "on" ?
                                                             Color(white: 1.0) : DarkGrayCustomizeColor)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: 50.0)
                                            .background(createReviseScheduleManager.action == "on" ?
                                                        GreenCustomizeColor : .clear)
                                            .cornerRadius(30.0)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30.0)
                                                    .inset(by: 1.0)
                                                    .stroke(createReviseScheduleManager.action == "on" ?
                                                        .clear : DarkGrayCustomizeColor, lineWidth: 2.0)
                                            )
                                    }).disabled(createReviseScheduleManager.action == "on")
                                    
                                    Button(action: {
                                        createReviseScheduleManager.action = "off"
                                    }, label: {
                                        Text("關閉").font(.custom("NotoSansTC-Medium", size: 20))
                                            .foregroundColor(createReviseScheduleManager.action == "off" ?
                                                             Color(white: 1.0) : DarkGrayCustomizeColor)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: 50.0)
                                            .background(createReviseScheduleManager.action == "off" ?
                                                        GreenCustomizeColor : .clear)
                                            .cornerRadius(30.0)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30.0)
                                                    .inset(by: 1.0)
                                                    .stroke(createReviseScheduleManager.action == "off" ?
                                                        .clear : DarkGrayCustomizeColor, lineWidth: 2.0)
                                            )
                                    }).disabled(createReviseScheduleManager.action == "off")
                                }.padding(.top, 24)
                            }
                            
                            Spacer()
                            
                            Group {
                                HStack {
                                    Button(action: {
//                                        print("Button cannel schedule")
                                        createReviseScheduleManager.showAlert = false
                                        createReviseScheduleManager.isCancel = true
                                        electricityScheduleManager.showAlert = true
                                    }, label: {
                                        Text("取消").font(.custom("NotoSansTC-Medium", size: 20))
                                            .foregroundColor(DarkGrayCustomizeColor)
                                            .frame(width: 144.0, height: 50.0)
                                            .background(GreyCustomizeColor)
                                            .cornerRadius(30.0)
                                    })
                                    
                                    Spacer()
                                    
                                    Button(action: {
//                                        print("Button set schedule")
                                        self.isLoaded = false
                                        createReviseScheduleManager.isCancel = false
//                                        electricityScheduleManager.isHistoryPage = false
                                        if isCreateSchedule{
                                            CreateNewSchedule(createReviseScheduleManager.deviceId, createReviseScheduleManager.action, createReviseScheduleManager.schedFreq, createReviseScheduleManager.weekOnOffArray, currentTime)
                                        }
                                        else{
                                            ReviseSchedule(createReviseScheduleManager.deviceId, createReviseScheduleManager.triggerName,
                                                           createReviseScheduleManager.action, createReviseScheduleManager.schedFreq,
                                                           createReviseScheduleManager.weekOnOffArray, currentTime,
                                                           createReviseScheduleManager.enable)
                                        }
                                        
                                    }, label: {
                                        Text("確認").font(.custom("NotoSansTC-Medium", size: 20))
                                            .foregroundColor( createReviseScheduleManager.schedFreq == "once" ||
                                                              createReviseScheduleManager.weekOnOffArray.contains(true) ?
                                                              Color(white: 1.0) : DarkGrayCustomizeColor)
                                            .frame(width: 144.0, height: 50.0)
                                            .background(createReviseScheduleManager.schedFreq == "once" || createReviseScheduleManager.weekOnOffArray.contains(true) ?
                                                        GreenCustomizeColor : GreyCustomizeColor)
                                            .cornerRadius(30.0)
                                    }).disabled(!createReviseScheduleManager.weekOnOffArray.contains(true) &&
                                                createReviseScheduleManager.schedFreq == "weekly")
                                }.padding(.top, 50)
                            }
                        }
                        .padding(.bottom, 30).padding(.horizontal, 26).padding(.top, 25)
                        .frame(width: geometry.size.width, height: createReviseScheduleManager.schedFreq == "weekly" ?
                               geometry.size.height + 98 :  geometry.size.height )

                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, 12)
            
            if(!self.isLoaded){
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
                    .scaleEffect(2)
            }
            
        }.onAppear{
            print("開啟 CreateReviseSchedule 頁面")
            // MARK: 等待
            Thread.sleep(forTimeInterval: 0.1)
            self.isLoaded = true
            
        }.onDisappear(){
            self.isLoaded = false
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func CreateNewSchedule(_ deviceId: String, _ action: String, _ schedFreq: String, _ schedWeekArray: [Bool], _ currentDate: Date){
        print("開始進行 CreateNewSchedule")
        
        //取schedTime
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone.current // 使用現在的時區
        let schedTime = timeFormatter.string(from: currentDate)
        
        //取schedDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current // 使用現在的時區
        let schedDate = dateFormatter.string(from: currentDate)
        
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
        
//        print(deviceId)
//        print(action)
//        print(schedFreq)
//        print(schedWeekArray)
//        print(schedWeek)
//        print(schedTime)
//        print(schedDate)

        POST_URLRequest_CloudRemote_Schedule_Create(deviceId, action, schedFreq, schedTime, schedDate, schedWeek)
        
    }
    
    // MARK: - 新增排程內容
    func POST_URLRequest_CloudRemote_Schedule_Create(_ deviceId : String, _ action: String, _ schedFreq : String,
                                                     _ schedTime : String, _ schedDate : String, _ schedWeek : String) {
        
        
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let url = PocUrl + "/api/main/cloud-remote/schedule?deviceId=\(deviceId)&action=\(action)&schedFreq=\(schedFreq)&schedTime=\(schedTime)&schedDate=\(schedDate)&schedWeek=\(schedWeek)"
        
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
                print("連線到伺服器 (POST cloud-remote schedule)")
                //                print(response)
                // MARK: 解析json
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    let code = json?["code"] as? Int
                    let message = json?["message"] as? String
//                    print("code: \(code)")
//                    print("message: \(message)")
                    
                    if code == 200 {
//                        let data = json?["data"] as? String
//                        print(data)
                        
                        Thread.sleep(forTimeInterval: 0.1)
                        self.isLoaded = true
                        
                        DispatchQueue.main.async {
                            electricityCustomAlertManager.message = "新增完成"
                            electricityCustomAlertManager.isPresented = true
                        }
                        print("POST cloud-remote schedule pass (create)")
                    }
                    else{
                        Thread.sleep(forTimeInterval: 0.1)
                        self.isLoaded = true
                   
                        DispatchQueue.main.async {
                            electricityCustomAlertManager.message = "新增失敗"
                            electricityCustomAlertManager.isPresented = true
                        }
                        print("POST cloud-remote schedule fail (create) message : \(String(describing: message))")
                    }
                    
                } catch {
                    Thread.sleep(forTimeInterval: 0.1)
                    self.isLoaded = true
                    
                    DispatchQueue.main.async {
                        electricityCustomAlertManager.message = "新增失敗"
                        electricityCustomAlertManager.isPresented = true
                    }
                    print(error)
                    loginflag = true
                }
        }
        task.resume()
    }
    
    func ReviseSchedule(_ deviceId: String, _ triggerName: String,
                        _ action: String, _ schedFreq: String,
                        _ schedWeekArray: [Bool], _ currentDate: Date,
                        _ enable : String){
        print("Start Revise Schedule")
        
        //取schedTime
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone.current // 使用現在的時區
        let schedTime = timeFormatter.string(from: currentDate)
        
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
    _ schedFreq : String, _ schedTime : String, _ schedDate : String,_ enable : String, _ schedWeek : String) {

        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
//        let url = PocUrl + "/api/main/cloud-remote/schedule?deviceId=\(deviceId)&triggerName=\(triggerName)&action=\(action)&schedFreq=\(schedFreq)&schedTime=\(schedTime)&enable=\(enable)&schedWeek=\(schedWeek)"
        
        var url = ""
        
        if(schedFreq == "once"){
            url = PocUrl + "/api/main/cloud-remote/schedule?deviceId=\(deviceId)&triggerName=\(triggerName)&action=\(action)&schedFreq=\(schedFreq)&schedTime=\(schedTime)&enable=\(enable)&schedDate=\(schedDate)"
        }
        else{
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
                
                if code == 200 {
                    //let data = json?["data"] as? String
                    //print(data)
                    Thread.sleep(forTimeInterval: 0.1)
                    self.isLoaded = true
                    
                    DispatchQueue.main.async {
                        electricityCustomAlertManager.message = "修改完成"
                        electricityCustomAlertManager.isPresented = true
                    }
                    
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
                self.isLoaded = true
                
                DispatchQueue.main.async {
                    electricityCustomAlertManager.message = "修改失敗"
                    electricityCustomAlertManager.isPresented = true
                }
                print(error)
                loginflag = true
            }
        }
        task.resume()
    }
}

class CreateReviseScheduleManager : ObservableObject {
    
    @Published var showAlert = false
    @Published var isCreateSchedule = true
    @Published var weekOnOffArray = [false, false, false, false, false, false, false]
    
    @Published var isCancel = false
    
    //用來更新時間
    @Published var currentSchedDate : Date = Date()
    
    @Published var deviceId : String = "N/A"
    @Published var action : String = "N/A"
    @Published var schedFreq : String = "N/A"
    @Published var schedTime : String = "N/A"
    @Published var schedDate : String = "N/A"
    
    @Published var triggerName : String = "N/A"
    @Published var enable : String = "N/A"
    @Published var schedWeek : String = "N/A"
}

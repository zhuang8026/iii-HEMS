//
//  ScheduleDeviceUIView.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/8.
//

import SwiftUI

struct ScheduleDeviceStruct {
    var devId:String?
    var devName:String?
    var devType:String?
    var activePower:String?
    var applianceType:String?
    var connectionStatus:String?
    var powerStatus:String?
    var schedulesCount:String?
    var scheduleInfoList:[String]?
    var schedulesExecutingCount: String?
}

// MARK: - 管理用電設備介面
struct ScheduleDeviceUIView: View {

    @Binding var showAlert: Bool
    var currentData: ScheduleDeviceStruct
    
    @EnvironmentObject var electricityScheduleManager : ElectricityScheduleManager
    
    @State var deviceName: String
    @State var iconName: String
    @State var deviceId: String
    //電源開關狀態
    @State var powerStatus: String
    //連線狀態
    @State var connectionStatus: String
    //瞬時瓦數
    @State var activePower: String
    //共有幾項排程
    @State var schedulesCount: String
    //幾項排程執行中
    @State var schedulesExecutingCount: String
    
    @State private var isEnabled = false
    @State private var shouldDetectToggleChange = false //是否該偵測Toggle變化

    init(showAlert: Binding<Bool>, deviceData: ScheduleDeviceStruct) {
        _showAlert = showAlert
        self.currentData = deviceData
                
        deviceName = currentData.devName ?? "N/A"
        iconName = getScheduleDeviceImageName(deviceData.devName ?? "N/A")
        deviceId = currentData.devId ?? "N/A"
        powerStatus = currentData.powerStatus ?? "N/A"
        connectionStatus = currentData.connectionStatus ?? "N/A"
        activePower = currentData.activePower ?? "N/A"
        schedulesCount = currentData.schedulesCount ?? "N/A"
        schedulesExecutingCount = currentData.schedulesExecutingCount ?? "N/A"
    }
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0){
                HStack{
                    Text(deviceName).foregroundColor(DarkGrayCustomizeColor)
                        .padding(.leading,26).font(.custom("NotoSansTC-Medium", size: 26.0))
                    Spacer()
                    Toggle("", isOn: $isEnabled).toggleStyle(PowerStatusToggleStyle())
                        .onChange(of: isEnabled){value in
                            if(self.shouldDetectToggleChange)
                            {
                                //print("Toggle : " + String(value))
                                POST_URLRequest_cloud_remote_on_off(deviceId, value)
                            }
                            
                        }
                        .disabled(!shouldDetectToggleChange || connectionStatus != "1")
                    if(self.isEnabled){
                        Text("開啟中").foregroundColor(Color(white: 1.0)).font(.custom("NotoSansTC-Medium", size: 18))
                            .padding(.trailing, 25).padding(.leading, 13)
                    }
                    else{
                        Text("關閉中").foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                            .font(.custom("NotoSansTC-Medium", size: 18))
                            .padding(.trailing, 25).padding(.leading, 13)
                    }
                }.padding(.top, 20)
                
                Text(deviceId)
                    .font(.custom("NotoSansTC-Medium", size: 18.0))
                    .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                    .padding(.leading, 26).padding(.top, 16)
                
                Group{
                    HStack{
                        if(connectionStatus == "1"){
                            Image("icon-wifi-connected").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                            Text("連線中").font(.custom("NotoSansTC-Medium", size: 18.0))
                                .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                        }
                        else{
                            Image("icon-wifi-disconnected").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                            Text("斷線中").font(.custom("NotoSansTC-Medium", size: 18.0))
                                .foregroundColor(Color(white: 1.0))
                        }
                    }
                    .frame(width: 98, height: 30)
                    .background(connectionStatus == "1" ? Color(red: 127.0 / 255.0, green: 213.0 / 255.0, blue: 204.0 / 255.0) :
                                    Color(red: 1.0, green: 108.0 / 255.0, blue: 108.0 / 255.0))
                    .cornerRadius(15.0).padding(.leading, 19)
                    .padding(.top, 8)
                    
                    HStack{
                        Image("icon-active-power").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                        HStack{
                            let a = Text(self.activePower)
                            let b = Text(" W")
                            
                            Text("\(a)\(b)")
                                .font(.custom("NotoSansTC-Medium", size: 18.0))
                                .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                        }
                    }.padding(.leading, 26).padding(.top, 10)
                    
                    HStack{
                        Image("icon-schedules-count").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                        HStack{
                            let a = Text(self.schedulesExecutingCount)
                            let b = Text(" 項排程執行中")
                            
                            Text("\(a)\(b)")
                                .font(.custom("NotoSansTC-Medium", size: 18.0))
                                .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                        }
                    }.padding(.leading, 26).padding(.top, 10)
                }
                
                Spacer()
                                
            }
                        
            VStack{
                Spacer()
                HStack (alignment: .bottom){
                    
                    Button(action: {
                        electricityScheduleManager.deviceId = deviceId
                        electricityScheduleManager.deviceName = deviceName
                        electricityScheduleManager.showAlert = true
                    }, label: {
                        Text("排程管理")
                            .font(.custom("NotoSansTC-Medium", size: 18))
                            .foregroundColor(self.isEnabled ? GreenCustomizeColor : Color(white: 1.0))
                            .frame(width: 111.0, height: 40.0)
                            .background(self.isEnabled ? Color(white: 1.0) : Color(red: 201.0 / 255.0, green: 207.0 / 255.0, blue: 229.0 / 255.0))
                            .cornerRadius(20.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20.0)
                                    .inset(by: 1.0)
                                    .stroke(self.isEnabled ? GreenCustomizeColor : Color(white: 1.0), lineWidth: 2.0)
                            ).padding(.leading, 26)
                    })
                    
                    Spacer()
                    if(iconName == "icon_10")
                    {
                        Image(self.isEnabled ?  iconName : String(iconName + "_gray")).resizable().scaledToFit()
                            .frame(width: 126, alignment: .center)
                    }
                    else{
                        Image(self.isEnabled ?  iconName : String(iconName + "_gray")).resizable().scaledToFit()
                            .frame(height: 72, alignment: .center)
                            .padding(.trailing, 25)
                    }
                    
                }
            }.padding(.bottom, 16)
        }
        .aspectRatio(351/300, contentMode: .fit)
        .background(self.isEnabled ? Color(red: 127.0 / 255.0, green: 213.0 / 255.0, blue: 204.0 / 255.0) :
                        GreyCustomizeColor)
        .cornerRadius(10)
        .shadow(color: Color(white: 0.0, opacity: 0.3), radius: 3.0, x: 0.0, y: 0.0)
        
        .onAppear{
            if(powerStatus == "1"){
                self.isEnabled = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                self.shouldDetectToggleChange = true
            }
        }
    }
    
    func POST_URLRequest_cloud_remote_on_off(_ deviceId : String, _ onOff : Bool){
                                    
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token")!
        let url = PocUrl + "api/main/cloud-remote/on-off"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        //設置參數
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                      
        // 設置內容
        let onoff : Int = onOff ? 1 : 0
        let body = "deviceId=\(deviceId)&onOff=\(String(onoff))"
        request.httpBody = body.data(using: .utf8)
                        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
                print("連線到伺服器 (POST cloud-remote/on-off)")
//                print(response)
//                print(data)
                
//                // MARK: 解析json
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                    print(json)
                    let code : Int = json?["code"] as? Int ?? 0
//                    let message = json?["message"] as? String
//                    print(code)
//                    print(message)
                    
                    let dataDict = json?["data"] as? [String: Any]
                    let dev_id = dataDict?["dev_id"] as? String
                    let value = dataDict?["value"] as? String
                    
                    if code == 200 {
                        print( (dev_id ?? "null") + " : cloud-remote/on-off set => " +  (value ?? "null"))
                        print("POST cloud-remote/on-off Pass")
                    }
                                 
                } catch {
                    print(error)
                }
        }
        task.resume()
    }
}

func getScheduleDeviceImageName(_ name:String) -> String{
    
    var retStr : String = ""
    
    switch (name){

//        case "tv":              //電視
//            retStr = "icon_1"
//        case "fridge":          //冰箱
//            retStr = "icon_2"
//        case "ac":              //冷氣
//            retStr = "icon_3"
//        case "water_boiler":    //開飲機
//            retStr = "icon_4"
//        case "washing_machine": //洗衣機
//            retStr = "icon_5"
//        case "dehumidifier":    //除濕機
//            retStr = "icon_6"
//        case "computer":        //電腦
//            retStr = "icon_7"
//        case "electric_pot":    //電鍋
//            retStr = "icon_8"
//        case "electric_fan":    //電風扇
//            retStr = "icon_9"
//        case "other":           //其他
//            retStr = "icon_10"
        
    case "電視":              //電視
        retStr = "icon_1"
    case "冰箱":              //冰箱
        retStr = "icon_2"
    case "冷氣":              //冷氣
        retStr = "icon_3"
    case "開飲機":            //開飲機
        retStr = "icon_4"
    case "洗衣機":            //洗衣機
        retStr = "icon_5"
    case "除濕機":            //除濕機
        retStr = "icon_6"
    case "電腦":              //電腦
        retStr = "icon_7"
    case "電鍋":              //電鍋
        retStr = "icon_8"
    case "電風扇":            //電風扇
        retStr = "icon_9"
    case "其他":              //其他
        retStr = "icon_10"

    default:
        retStr = "icon_10"
    }
    
    return retStr
}

struct PowerStatusToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // Insert custom View code here.
        HStack {
            configuration.label
            Spacer()
            ZStack{
                Capsule()
                .foregroundColor(configuration.isOn ? GreenCustomizeColor :
                                    Color(red: 201.0 / 255.0, green: 207.0 / 255.0, blue: 229.0 / 255.0))
                .frame(width: 60, height: 30, alignment: .center)
                .overlay(
                    Circle()
                        .scaleEffect(0.8)
                        .foregroundColor(configuration.isOn ? Color.white : Color.white)
                        .offset(x: configuration.isOn ? 15 : -15, y: 0)
//                        .animation(Animation.linear(duration: 0.1))
                        .animation(.linear(duration: 0.1), value: configuration.isOn)
      
                )
                .onTapGesture { configuration.isOn.toggle() }
            }
        }
    }
}

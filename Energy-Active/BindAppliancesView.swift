//
//  BindAppliancesView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/8.
//

import Foundation
import SwiftUI
import WebKit

struct BindAppliancesView: View {
    
    @Binding var loginflag:Bool
    @State var isLoaded = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var firstSelectedOption: String = ""
    @State private var secondSelectedOption: String = ""
    @State private var thirdSelectedOption: String = ""
    
    @State private var selectedOptions: [String] = ["", "", ""]
    @State private var selectedOptionsID: [String] = ["", "", ""]
    @State private var options = [String]()
    @State private var devicesOptions = [DeviceInformation]()
    @State private var optionsInt :[Int] = [0 , 0 , 0]
    @State private var selectedIndex = 0
    @State private var showAlert = false
    @State private var alertTitleMessage : String = ""
    @State private var alertMessage : String = ""
    
    var body: some View {
        
        ZStack{
//            Color.init(hex: "#e9ecd9", alpha: 1.0)
            Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0).ignoresSafeArea(.all, edges: .top)
            
            VStack{
                Text("綁定電器").font(.custom("NotoSansTC-Medium", size: 20))
                    .foregroundColor(DarkGrayCustomizeColor)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
                    .padding(.top, 15)
                
//                Divider().padding(.horizontal)
                
                //對應插座ID/
                Text("綁定電器").font(.custom("NotoSansTC-Medium", size: 14))
                    .foregroundColor(DarkGrayCustomizeColor)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                    .padding(.horizontal, 10).padding(.top, 15)
                
                Group{
                                        
                    VStack {
                        ForEach(0..<3) { index in
                            Menu {
                                ForEach(options.filter {
                                    !selectedOptions.contains($0) || $0 == selectedOptions[index]
                                }, id: \.self) { option in
                                    Button(action: {
                                        selectedOptions[index] = option
                                    }) {
                                        Text(option).font(.custom("NotoSansTC-Medium", size: 18))
                                            .foregroundColor(DarkGrayCustomizeColor)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedOptions[index])
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .font(.custom("NotoSansTC-Medium", size: 18))
                                        .foregroundColor(DarkGrayCustomizeColor)
                                        

                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .frame(height : 52)                            
                            .padding(.horizontal, 10)
                            .background(GreyCustomizeColor)
                            .cornerRadius(5.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .inset(by: 0.5)
                                    .stroke(Color(white: 204.0 / 255.0), lineWidth: 1.0)
                            )
                            .padding(.horizontal, 10)
                            
                            Text(selectedOptionsID[index])
                                .font(.custom("NotoSansTC-Medium", size: 16))
                                .foregroundColor(Color.init(hex: "#76839c", alpha: 1.0))
                                .padding(.leading, 12)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .frame(height : 52)
                                .background(.clear)
                                .cornerRadius(5.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5.0)
                                        .inset(by: 0.5)
                                        .stroke(Color(white: 204.0 / 255.0), lineWidth: 1.0)
                                )
                                .padding(.horizontal, 10)
                        }
                    }
                }
                
                Spacer()
                      
                HStack{
                    
                    Button {
                        self.isLoaded = false
                        print("按下確認")
                        var devicesNum : [Int] = [0,0,0]
                        

                        for i in 0 ... selectedOptions.count - 1{
                            for j in 0 ... devicesOptions.count - 1{
                                if (selectedOptions[i] == devicesOptions[j].Device_Name)
                                {
                                    devicesNum[i] = devicesOptions[j].Device_Number
                                    break
                                }
                            }
                        }
                        POST_URLRequest_Device_Bind(devicesNum, selectedOptionsID)
                    } label: {
                        
                        Text("確認").font(.custom("NotoSansTC-Medium", size: 14))//.font(.system(size: 16))
                            .foregroundColor(AlertSureButtonColor)
                            .frame(height: 40)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .background(Color(red: 40.0 / 255.0, green: 180.0 / 255.0, blue: 179.0 / 255.0))
                            .cornerRadius(40.0)
                            .shadow(color: Color(white: 0.0, opacity: 0.16), radius: 3.0, x: 0.0, y: 3.0)
                            .padding(.bottom, 15)
                
                    }
                }
                .padding(.horizontal, 13)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .aspectRatio(351/567, contentMode: .fit)
            .background(BackgroundColor)
            .cornerRadius(5)
            .padding(.horizontal, 12)
            
            if(!self.isLoaded){
                
                
                Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
                    .scaleEffect(2)
            }
            
            
        } .onAppear{
            self.isLoaded = false
                        
            CreateDeviceNameList()
            GET_URLRequest_Cloud_Remote()
            
        }
        .alert(isPresented: $showAlert, content: {
                    Alert(title: Text(alertTitleMessage),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("確定")))
                })
    }
    

    
    func CreateDeviceNameList(){

                
        //舊版清單從首頁取得
//        var count = 0
//        count = self.devicesOptions.count
        
//        self.devicesOptions = [DeviceInformation]()
//        for i in 0 ... otherApplianceData.count - 1{
//
//            if(otherApplianceData[i].cnName == "冷氣" || otherApplianceData[i].cnName == "冰箱" || otherApplianceData[i].cnName == "其他"){
//               //跳過不顯示
//            }
//            else{
//                devicesOptions.append(DeviceInformation(Device_Number: count + 1, Device_Name: otherApplianceData[i].cnName!))
//                count += 1
//            }
//        }
        
        //新版清單直接寫入
        self.devicesOptions = LoadDevicesInformation()
        
        
        self.options = [String]()
        
        for j in 0 ... devicesOptions.count - 1{
//            print(devicesOptions[j].Device_Number)
//            print(devicesOptions[j].Device_Name)
            print("device name = \(devicesOptions[j].Device_Name) , device id = \(devicesOptions[j].Device_Number)")
            self.options.append(devicesOptions[j].Device_Name)
        }
    }
    
    func LoadDevicesInformation() -> [DeviceInformation]{
        var devices = [DeviceInformation]()
        devices.append(DeviceInformation(Device_Number: 2, Device_Name: "電視"))
//        devices.append(DeviceInformation(Device_Number: 3, Device_Name: "冰箱"))
//        devices.append(DeviceInformation(Device_Number: 4, Device_Name: "冰箱"))
        devices.append(DeviceInformation(Device_Number: 5, Device_Name: "開飲機"))
        devices.append(DeviceInformation(Device_Number: 6, Device_Name: "洗衣機"))
        devices.append(DeviceInformation(Device_Number: 7, Device_Name: "電風扇"))
        devices.append(DeviceInformation(Device_Number: 8, Device_Name: "電腦"))
        devices.append(DeviceInformation(Device_Number: 9, Device_Name: "電鍋"))
        devices.append(DeviceInformation(Device_Number: 11, Device_Name: "除濕機"))
        return devices
    }
    
    func POST_URLRequest_Device_Bind(_ numberList:[Int], _ cnNameList:[String]){
        
        let numberListString = numberList.map { String($0) }
        let appIdList = numberListString.joined(separator: ",")
        let socketList = cnNameList.joined(separator: ",")
//        print("POST => device name = \(socketList) , device id = \(appIdList)")
            
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "appIdList", value: appIdList),
            URLQueryItem(name: "socketList", value: socketList),
        ]
        let query = components.percentEncodedQuery ?? ""
        let data = Data(query.utf8)
                
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token")!
//        let url = Ntpc3Url + "api/main/device/bind"
        let url = PocUrl + "api/main/device/bind"
        
        var request = URLRequest(url: URL(string: url)!)

        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = data
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (POST device/bind)")
            //                print(response)
            //                print(data)
            
            //                // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //                    print(json)
                if(code == 200){
                    //                        print(json)
                    self.isLoaded = true
                    self.alertTitleMessage = "綁定成功"
                    self.alertMessage = ""
                    self.showAlert = true
                }
                else if(code == 4002){
                    //權限錯誤返回首頁
                    loginflag = true
                }
                else{
                    self.isLoaded = true
                    let message = json?["message"] as? String ?? "null"
                    self.alertTitleMessage = "錯誤"
                    self.alertMessage = message
                    self.showAlert = true
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func GET_URLRequest_Cloud_Remote(){
     
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token")!
        //        let url = Ntpc3Url + "api/main/cloud-remote"
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
            
            //                // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //                    print(json)
                
                var count = 0
                
                if(code == 200){
                    if let data = json?["data"] as? [String:Any], let scheduleDevices = data["scheduleDevices"] as? [[String:Any]] {
                        for device in scheduleDevices {
                            if let devId = device["devId"] as? String, let devName = device["devName"] as? String {
                                print("Device ID: \(devId), Device Name: \(devName)")
                                self.selectedOptions[count] = devName
                                self.selectedOptionsID[count] = devId
                                count += 1
                            }
                        }
                        self.isLoaded = true
                    }
                }
                else if(code == 4002){
                    //back to login
                    loginflag = true
                }
                else{
                    //back to login
                    loginflag = true
                }
                
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct DeviceInformation {
    let Device_Number: Int
    let Device_Name: String
}


//
//  Electricity_MsgAlert.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/8.
//

import SwiftUI

// MARK: - 用電建議介面

extension View {
    
    func environmentElectricity_MsgAlertView(showAlert: Binding <Bool>) -> some View {
        self.modifier(environmentElectricity_MsgAlert(showAlert: showAlert)
        )
    }
}

struct environmentElectricity_MsgAlert : ViewModifier {
    
    @EnvironmentObject var electricity_msgManager : Electricity_MsgManager
    
    @Binding var showAlert: Bool
    @State var isClick = false
    @State var isLoaded = false
    
    func body(content: Content) -> some View {
    
        ZStack { content
            if showAlert {
                withAnimation {
                    showElectricity_MsgAlert()
                }
            }
        }
    }
}

extension environmentElectricity_MsgAlert {

    func showElectricity_MsgAlert() -> some View  {
        ZStack{
            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showAlert = false
                }
            
            if(isLoaded)
            {
                VStack (spacing: 0){
                    ZStack{
                        Text("管理建議").font(.custom("NotoSansTC-Medium", size: 24))
                            .foregroundColor(DarkGrayCustomizeColor)
                            .padding(.top, 20)
                        HStack{
                            Spacer()
                            Button {
                                showAlert = false
                            } label: {
                                Image(systemName: "xmark").resizable().scaledToFit()
                                    .frame(width: 17.0, height: 17.0)
                                    .foregroundColor(Color(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0))
                            }
                        }.padding(.trailing, 25).padding(.top, 25)
                    }
                    
                    if(electricity_msgManager.ElectricityMsg.count > 0)
                    {
                        ScrollView {
                            ForEach(0..<electricity_msgManager.ElectricityMsg.count, id: \.self){  index in
                                VStack (spacing: 0){
                                    
                                    VStack (alignment: .leading){
                                        Text(electricity_msgManager.ElectricityMsg[index].sendTime + " " + electricity_msgManager.ElectricityMsg[index].advice)
                                            .font(.custom("NotoSansTC-Medium", size: 16))
                                            .foregroundColor(DarkGrayCustomizeColor)
                                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 12, trailing: 15))
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                                    .cornerRadius(5)
                                    .padding(.horizontal, 25)
                                    .padding(.top, 30)
                                    
                                    Text("上述建議是否對您有幫助？").font(.custom("NotoSansTC-Medium", size: 16.0))
                                        .foregroundColor(DarkGrayCustomizeColor)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 10).padding(.leading, 26)
                                    
                                    HStack {
                                        Button(action: {
                                            print("Button Yes")
                                            //                                            self.ElectricityMsg[index].response = "1"
                                            POST_URLRequest_adv_msg(electricity_msgManager.ElectricityMsg[index].sendTime, electricity_msgManager.ElectricityMsg[index].advice, "1", index)
                                        }, label: {
                                            Text("是").font(.custom("NotoSansTC-Medium", size: 20))
                                                .foregroundColor(electricity_msgManager.ElectricityMsg[index].response == "1" ?
                                                                 Color(white: 1.0) : DarkGrayCustomizeColor)
                                                .frame(width: 144.0, height: 40.0)
                                                .background(electricity_msgManager.ElectricityMsg[index].response == "1" ?
                                                            GreenCustomizeColor : GreyCustomizeColor)
                                                .cornerRadius(40.0)
                                        }).disabled(electricity_msgManager.ElectricityMsg[index].response == "1" || electricity_msgManager.ElectricityMsg[index].response == "0")
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            print("Button No")
                                            //                                            self.ElectricityMsg[index].response = "0"
                                            POST_URLRequest_adv_msg(electricity_msgManager.ElectricityMsg[index].sendTime, electricity_msgManager.ElectricityMsg[index].advice, "0", index)
                                        }, label: {
                                            Text("否").font(.custom("NotoSansTC-Medium", size: 20))
                                                .foregroundColor(electricity_msgManager.ElectricityMsg[index].response == "0" ?
                                                                 Color(white: 1.0) : DarkGrayCustomizeColor)
                                                .frame(width: 144.0, height: 40.0)
                                                .background(electricity_msgManager.ElectricityMsg[index].response == "0" ?
                                                            GreenCustomizeColor : GreyCustomizeColor)
                                                .cornerRadius(40.0)
                                        }).disabled(electricity_msgManager.ElectricityMsg[index].response == "1" || electricity_msgManager.ElectricityMsg[index].response == "0")
                                    }.padding(.horizontal, 25).padding(.top, 3)
                                }
                            }
                        }.padding(.bottom, 30)
                    }
                    else{
                        VStack{
                            Image("icon-schedule-no-data").resizable().scaledToFit().frame(width: 60.0, height: 60.0)
                            Text("暫無資料").font(.custom("NotoSansTC-Medium", size: 16.0))
                        }
                        .padding(.vertical,70)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                        .cornerRadius(10.0)
                        .padding(.horizontal,25).padding(.bottom, 25).padding(.top,30)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.9)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 12)
            }
        }.onAppear{
            print("開啟 Electricity_MsgAlert 頁面")
            print("取得 ElectricityMsg 個數 : " + String(electricity_msgManager.ElectricityMsg.count))
            // MARK: 等待
            Thread.sleep(forTimeInterval: 0.1)
            self.isLoaded = true
            
        }.onDisappear(){
            self.isLoaded = false
        }
        
    }
    
    // MARK: - 回傳選項內容
    func POST_URLRequest_adv_msg(_ send_time : String, _ advice: String, _ tick : String, _ index : Int){
        
        let session = URLSession(configuration: .default)
        // 設定URL
        let url = PocUrl + "/api/nilm09/adv_msg"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let user_id = CurrentUserID
        let postData = ["user_id":user_id, "send_time":send_time, "advice":advice, "tick":tick]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
            request.httpBody = jsonData
        } catch {
            
        }
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            
            print("連線到伺服器 (POST adv_msg)")
            //                print(response)
            
            // MARK: 解析json
            //                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            //                    let code = json?["code"] as? Int
            //                    let message = json?["message"] as? String
            //                    print("code: \(code)")
            //                    print("message: \(message)")
            
            //                    let dataDict = json?["data"] as? [String: Any]
            //                    let userId = dataDict?["user_id"] as? String
            //                    let send_time = dataDict?["send_time"] as? String
            //                    let advice = dataDict?["advice"] as? String
            //                    let tick = dataDict?["tick"] as? String
            
            //                    print(userId)
            //                    print(send_time)
            //                    print(advice)
            //                    print(tick)
            print("POST adv_msg Pass")
            
            self.electricity_msgManager.ElectricityMsg[index].response = tick
        }
        task.resume()
    }
}

// MARK: - 用電建議介面   //舊版
//struct Electricity_MsgAlert: View {
//    
//    @Binding var showAlert: Bool
//    
//    @State var ElectricityMsg: [ElectricityMsgInfo]
//    
//    @State var isClick = false
//    @State var isLoaded = false
//    
//    
//    var body: some View {
//        
//        ZStack{
//            Color(white: 0.0, opacity: 0.4)
//                .onTapGesture {
//                    showAlert = false
//                }
//            
//            if(isLoaded)
//            {
//                VStack (spacing: 0){
//                    ZStack{
//                        Text("管理建議").font(.custom("NotoSansTC-Medium", size: 24))
//                            .foregroundColor(DarkGrayCustomizeColor)
//                            .padding(.top, 20)
//                        HStack{
//                            Spacer()
//                            Button {
//                                showAlert = false
//                            } label: {
//                                Image(systemName: "xmark").resizable().scaledToFit()
//                                    .frame(width: 17.0, height: 17.0)
//                                    .foregroundColor(Color(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0))
//                            }
//                        }.padding(.trailing, 25).padding(.top, 25)
//                    }
//                          
//                        ScrollView {
//                            ForEach(0..<ElectricityMsg.count){  index in
//                                VStack (spacing: 0){
//                                    
//                                    VStack (alignment: .leading){
//                                        Text(ElectricityMsg[index].sendTime + " " + ElectricityMsg[index].advice)
//                                            .font(.custom("NotoSansTC-Medium", size: 16))
//                                            .foregroundColor(DarkGrayCustomizeColor)
//                                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 12, trailing: 15))
//                                    }
//                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                                    .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
//                                    .cornerRadius(5)
//                                    .padding(.horizontal, 25)
//                                    .padding(.top, 30)
//                                    
//                                    Text("上述建議是否對您有幫助？").font(.custom("NotoSansTC-Medium", size: 16.0))
//                                        .foregroundColor(DarkGrayCustomizeColor)
//                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                                        .padding(.top, 10).padding(.leading, 26)
//                                    
//                                    HStack {
//                                        Button(action: {
//                                            print("Button Yes")
////                                            self.ElectricityMsg[index].response = "1"
//                                            POST_URLRequest_adv_msg(ElectricityMsg[index].sendTime, ElectricityMsg[index].advice, "1", index)
//                                        }, label: {
//                                            Text("是").font(.custom("NotoSansTC-Medium", size: 20))
//                                                .foregroundColor(ElectricityMsg[index].response == "1" ? Color(white: 1.0) :
//                                                                    DarkGrayCustomizeColor)
//                                                .frame(width: 144.0, height: 40.0)
//                                                .background(ElectricityMsg[index].response == "1" ? GreenCustomizeColor : GreyCustomizeColor)
//                                                .cornerRadius(40.0)
//                                        }).disabled(ElectricityMsg[index].response == "1" || ElectricityMsg[index].response == "0")
//                                        
//                                        Spacer()
//                                        
//                                        Button(action: {
//                                            print("Button No")
////                                            self.ElectricityMsg[index].response = "0"
//                                            POST_URLRequest_adv_msg(ElectricityMsg[index].sendTime, ElectricityMsg[index].advice, "0", index)
//                                        }, label: {
//                                            Text("否").font(.custom("NotoSansTC-Medium", size: 20))
//                                                .foregroundColor(ElectricityMsg[index].response == "0" ? Color(white: 1.0) :
//                                                                    DarkGrayCustomizeColor)
//                                                .frame(width: 144.0, height: 40.0)
//                                                .background(ElectricityMsg[index].response == "0" ? GreenCustomizeColor : GreyCustomizeColor)
//                                                .cornerRadius(40.0)
//                                        }).disabled(ElectricityMsg[index].response == "1" || ElectricityMsg[index].response == "0")
//                                    }.padding(.horizontal, 25).padding(.top, 3)
//                                }
//                            }
//                        }.padding(.bottom, 30)
//                }
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.95)
//                .fixedSize(horizontal: false, vertical: true)
//                .background(Color.white)
//                .cornerRadius(10)
//                .padding(.horizontal, 12)
//                .edgesIgnoringSafeArea(.all)
//            }
//        }.onAppear{
//            print("開啟 Electricity_MsgAlert 頁面")
//            
//            // MARK: 等待
//            Thread.sleep(forTimeInterval: 0.1)
//            self.isLoaded = true
//            
//        }.onDisappear(){
//            self.isLoaded = false
//        }
//    }
//    
//    // MARK: - 回傳選項內容
//    func POST_URLRequest_adv_msg(_ send_time : String, _ advice: String, _ tick : String, _ index : Int){
//        
//        let session = URLSession(configuration: .default)
//        // 設定URL
//        let url = PocUrl + "/api/nilm09/adv_msg"
//        var request = URLRequest(url: URL(string: url)!)
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        
//        let user_id = CurrentUserID
//        let postData = ["user_id":user_id, "send_time":send_time, "advice":advice, "tick":tick]
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
//            request.httpBody = jsonData
//        } catch {
//            
//        }
//        
//        // 接收回傳的task
//        let task = session.dataTask(with: request) {(data, response, error) in
//            do {
//                print("連線到伺服器 (POST adv_msg)")
//                //                print(response)
//                
//                // MARK: 解析json
//                do {
//                    
//                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                    let code = json?["code"] as? Int
//                    let message = json?["message"] as? String
////                    print("code: \(code)")
////                    print("message: \(message)")
//                    
//                    let dataDict = json?["data"] as? [String: Any]
//                    let userId = dataDict?["user_id"] as? String
//                    let send_time = dataDict?["send_time"] as? String
//                    let advice = dataDict?["advice"] as? String
//                    let tick = dataDict?["tick"] as? String
//                    
////                    print(userId)
////                    print(send_time)
////                    print(advice)
////                    print(tick)
//                    print("POST adv_msg Pass")
//                    
//                    self.ElectricityMsg[index].response = tick ?? ""
//                    
//                } catch {
//                    print(error)
//                }
//                
//            } catch {
//                print(error)
//                return
//            }
//        }
//        task.resume()
//    }
//}

struct ElectricityMsgInfo {
    var sendTime : String
    var advice : String
    var response : String
}


// MARK: - test code
extension View {
    
    func progressView(
        isShowing: Binding <Bool>,
        backgroundColor: Color = .black,
        dimBackground: Bool = false,
        text : String? = nil,
        loaderColor : Color = .white,
        scale: Float = 1,
        blur: Bool = false) -> some View {
            
        self.modifier(ProgressViewModifier(
            isShowing: isShowing,
            backgroundColor: backgroundColor,
            dimBackground: dimBackground,
            text: text,
            loaderColor: loaderColor,
            scale: scale,
            blur: blur)
        )
    }
}

// MARK: - ProgressViewModifier

struct ProgressViewModifier : ViewModifier {
    @Binding var isShowing : Bool
    
    var backgroundColor: Color
    var dimBackground: Bool
    var text : String?
    var loaderColor : Color
    var scale: Float
    var blur: Bool
    
    func body(content: Content) -> some View {
    
        ZStack { content

            if isShowing {
                withAnimation {
                    showProgressView()
                }
            }
        }
    }
}

// MARK: - Private methods

extension ProgressViewModifier {
    
    private func showProgressView() -> some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor.opacity(0.7))
                .ignoresSafeArea()
                //.background(.ultraThinMaterial)
            VStack (spacing : 20) {
                if isShowing {
                    ProgressView()
                        .tint(loaderColor)
                        .scaleEffect(CGFloat(scale))
                    if text != nil {
                        Text(text!)
                        .foregroundColor(.black)
                        .font(.headline)
                    }
                }
            }
            .background(.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}





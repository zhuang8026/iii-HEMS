//
//  WarningCustomAlert.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/11.
//

import Foundation
import SwiftUI


// MARK: 三種彈跳視窗統一用這個Manager
class ElectricityTrackingAlertManager : ObservableObject {
    
    // MARK: - 警告視窗 參數
    @Published var showWarningCustomAlert = false
    @Published var currentData = ApplianceDataStruct()
//    @Published var forapp = Forapp()
    
    // MARK: - 每週提示視窗 參數
    @Published var showWeekly_MsgAlert = false
    @Published var performance = ""
    @Published var weekly_advice = ""
    
    // MARK: - 每日登入提示視窗 參數
    @Published var showContinuousLoginAlert = false
    @Published var loginday = 0
}

// MARK: - WarningCustomAlert View
extension View {
    func electricityWarningCustomAlertView(showAlert: Binding <Bool>, currentData: Binding <ApplianceDataStruct>, forapp: Binding <Forapp> ) -> some View {
        self.modifier(WarningCustomAlertModifier(showAlert: showAlert, currentData: currentData, forapp: forapp)
        )
    }
}

// MARK: - WarningCustomAlertModifier


struct WarningCustomAlertModifier : ViewModifier {
    
    @EnvironmentObject var electricityElectricityTrackingAlertManager : ElectricityTrackingAlertManager
    
    @Binding var showAlert: Bool
    @Binding var currentData: ApplianceDataStruct
    @Binding var forapp:Forapp
    @State var isClick = false
    @State var isLoaded = false
    
    @State var advice : String = "advice"
    @State var advice2 : String = "advice2"
    
    @State var response : String = "N/A"
    func body(content: Content) -> some View {
        
        ZStack{ content
            if showAlert {
                Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAlert = false
                    }
                VStack{
                    VStack {
                        if(isLoaded)
                        {
                            Text("用電提醒").font(.custom("NotoSansTC-Medium", size: 24)).padding(.top)
                            
                            Text(advice).font(.custom("NotoSansTC-Medium", size: 16))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            ScrollView {
                                Text("節電小秘訣").font(.custom("NotoSansTC-Medium", size: 24))
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                
                                Text(advice2).font(.custom("NotoSansTC-Medium", size: 16))
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            .foregroundColor(Color.init(hex: "#76839c", alpha: 1.0))
                            .padding()
                            .background(Color.init(hex: "#ebeefa", alpha: 1.0))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.init(hex: "#f3f3f3", alpha: 1.0) , lineWidth: 2)
                            ).padding(.horizontal)
                                .padding(.top)
                            
                            
                            if(isClick || response == "1" || response == "0")
                            //                        if(isClick)
                            {
                                Text("謝謝您的反饋")
                                    .font(.custom("NotoSansTC-Medium", size: 16))
                                    .foregroundColor(AlertCancelButtonColor)
                                    .padding(5)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .cornerRadius(10)
                                    .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AlertCancelButtonColor, lineWidth: 2)
                                    )
                                    .padding()
                            }
                            else{
                                Text("上述建議是否對您有幫助？").font(.custom("NotoSansTC-Medium", size: 16))
                                    .padding(EdgeInsets(top: 10, leading: 1, bottom: 1, trailing: 1))
                                HStack {
                                    Button(action: {
                                        POST_URLRequest_adv_war(self.advice, "0")
                                    }, label: {
                                        Text("否")
                                            .font(.custom("NotoSansTC-Medium", size: 16))
                                            .foregroundColor(AlertCancelButtonColor)
                                            .padding(10)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                            .background(AlertCancelButtonBackgroundColor)
                                            .cornerRadius(10)
                                        
                                    })
                                    .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                                    
                                    Button(action: {
                                        POST_URLRequest_adv_war(self.advice, "1")
                                    }, label: {
                                        Text("是")
                                            .foregroundColor(AlertSureButtonColor)
                                            .padding(10)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                            .background(AlertSureButtonBackgroundColor)
                                            .cornerRadius(10)
                                    }).font(.custom("NotoSansTC-Medium", size: 16))
                                        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                                }.padding(.top, 0)
                                    .padding([.leading, .trailing, .bottom])
                            }
                        }
                        else{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
                                .scaleEffect(2)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.5,  alignment: .center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 12)
                }
            }
        }.onChange(of: showAlert) { value in
            if value {
                print("開啟WarningCustomAlert 頁面")
                // MARK: 從這裡開始先刷新界面必備資料
                if(currentData.advice is String){
                    self.advice = currentData.advice as! String
                }
                else{
                    self.advice = "null"
                }
                
                Get_URLRequest_adv_war(self.advice)
                
                if(currentData.advice2 is String){
                    self.advice2 = currentData.advice2 as! String
                }
                else{
                    self.advice2 = "null"
                }
            }
        }.onDisappear(){
            self.isLoaded = false
        }
    }
    
    func Get_URLRequest_adv_war(_ advice: String){
        
        let session = URLSession(configuration: .default)
        let user_id = CurrentUserID
        // 設定URL
        let orgUrl = PocUrl +  "api/nilm09/adv_war?user_id=\(user_id)&advice=\(advice)"
        let url = orgUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            do {
                print("連線到伺服器 (Get adv_war)")
//                print(data)
//                print(response)
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                print(json)
                let dataDict = json?["data"] as? [String: Any]
                let r = dataDict?["response"] as? String
                
                self.response = r ?? ""
                print("response => \(self.response)")
                
                print("Get adv_war Pass")
                
                self.isLoaded = true
            } catch {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    func POST_URLRequest_adv_war(_ advice: String, _ tick : String){
        
        let session = URLSession(configuration: .default)
        // 設定URL
        let url = PocUrl + "api/nilm09/adv_war"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let user_id = CurrentUserID
        let postData = ["user_id":user_id,"advice":advice,"tick":tick]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
            request.httpBody = jsonData
        } catch {
            
        }
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            do {
                print("連線到伺服器 (POST adv_war)")
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                print(response)
//                print(json)
                
                Get_URLRequest_adv_war(self.advice)
                GET_URLRequest_Forapp()
                isClick = true
                
                print("POST adv_war Pass")
            } catch {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    struct ResponseData: Codable {
        let code: Int
        let message: String
        let data: Data
    }
    
    struct Data: Codable {
        let user_id: String
        let advice: String
        let tick: String
    }
    
    func GET_URLRequest_Forapp(){
        let session = URLSession(configuration: .default)
        let user_id = CurrentUserID
        // 設定URL
        let url = PocUrl +  "forapp?user_id=\(user_id)"
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
                //                    let code = json?["code"] as? Int
                //                    let message = json?["message"] as? String
                //                        print("code: \(code)")
                //                        print("message: \(message)")
                
                let dataDict = json?["app"] as? [String: Any]
//                let userId = dataDict?["user_id"] as? String
                let user_advice_bt = dataDict?["user_advice_bt"] as? String
                let weekly_monthly_report_bth = dataDict?["weekly_monthly_report_bth"] as? String
                let manage_control_advice_bth = dataDict?["manage_control_advice_bth"] as? String
                //                    print("user_id: \(userId)")
                //                    print("user_advice_bt: \(user_advice_bt)")
                //                    print("weekly_monthly_report_bth: \(weekly_monthly_report_bth)")
                //                    print("manage_control_advice_bth: \(manage_control_advice_bth)")
                
                forapp.User_advice_bt = Int(user_advice_bt!) ?? 0
                forapp.Weekly_monthly_report_bth = Int(weekly_monthly_report_bth!) ?? 0
                forapp.Manage_control_advice_bth = Int(manage_control_advice_bth!) ?? 0
                
                //testNumber
                //                    forapp.User_advice_bt = 8
                print("GET Forapp Pass")
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}




//struct WarningCustomAlert: View {
//    
//    @Binding var showAlert: Bool
//    @Binding var currentData: ApplianceDataStruct
//    @Binding var forapp:Forapp
//    @State var isClick = false
//    @State var isLoaded = false
//    
//    @State var advice : String = "advice"
//    @State var advice2 : String = "advice2"
//    
//    @State var response : String = "N/A"
//    var body: some View {
//        
//        ZStack{
//            
//            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showAlert = false
//                }
//            
//
//            VStack{
//                
//                VStack {
//                    if(isLoaded)
//                    {
//                        Text("用電提醒").font(.custom("NotoSansTC-Medium", size: 24)).padding(.top)
//                        
//                        Text(advice).font(.custom("NotoSansTC-Medium", size: 16))
//                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
//                            .fixedSize(horizontal: false, vertical: true)
//                        
//                        ScrollView {
//                            Text("節電小秘訣").font(.custom("NotoSansTC-Medium", size: 24))
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            
//                            Text(advice2).font(.custom("NotoSansTC-Medium", size: 16))
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                                .fixedSize(horizontal: false, vertical: true)
//                            
//                            Spacer()
//                        }
//                        .foregroundColor(Color.init(hex: "#76839c", alpha: 1.0))
//                        .padding()
//                        .background(Color.init(hex: "#ebeefa", alpha: 1.0))
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.init(hex: "#f3f3f3", alpha: 1.0) , lineWidth: 2)
//                        ).padding(.horizontal)
//                            .padding(.top)
//                        
//                        
//                        if(isClick || response == "1" || response == "0")
//                        //                        if(isClick)
//                        {
//                            Text("謝謝您的反饋")
//                                .font(.custom("NotoSansTC-Medium", size: 16))
//                                .foregroundColor(AlertCancelButtonColor)
//                                .padding(5)
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                                .cornerRadius(10)
//                                .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(AlertCancelButtonColor, lineWidth: 2)
//                                )
//                                .padding()
//                        }
//                        else{
//                            Text("上述建議是否對您有幫助？").font(.custom("NotoSansTC-Medium", size: 16))
//                                .padding(EdgeInsets(top: 10, leading: 1, bottom: 1, trailing: 1))
//                            HStack {
//                                Button(action: {
//                                    POST_URLRequest_adv_war(self.advice, "0")
//                                }, label: {
//                                    Text("否")
//                                        .font(.custom("NotoSansTC-Medium", size: 16))
//                                        .foregroundColor(AlertCancelButtonColor)
//                                        .padding(10)
//                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                                        .background(AlertCancelButtonBackgroundColor)
//                                        .cornerRadius(10)
//                                    
//                                })
//                                .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
//                                
//                                Button(action: {
//                                    POST_URLRequest_adv_war(self.advice, "1")
//                                }, label: {
//                                    Text("是")
//                                        .foregroundColor(AlertSureButtonColor)
//                                        .padding(10)
//                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                                        .background(AlertSureButtonBackgroundColor)
//                                        .cornerRadius(10)
//                                }).font(.custom("NotoSansTC-Medium", size: 16))
//                                    .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
//                            }.padding(.top, 0)
//                                .padding([.leading, .trailing, .bottom])
//                        }
//                    }
//                    else{
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
//                            .scaleEffect(2)
//                    }
//                }
//                .frame(height: UIScreen.main.bounds.height * 0.5,  alignment: .center)
//                .frame(minWidth: 0, maxWidth: .infinity)
//                .background(Color.white)
//                .cornerRadius(10)
//                .padding(.horizontal, 12)
//            }
//            
//        }.onAppear{
//            print("開啟WarningCustomAlert 頁面")
//            // MARK: 從這裡開始先刷新界面必備資料
//            if(currentData.advice is String){
//                self.advice = currentData.advice as! String
//            }
//            else{
//                self.advice = "null"
//            }
//            
//            Get_URLRequest_adv_war(self.advice)
//            
//            if(currentData.advice2 is String){
//                self.advice2 = currentData.advice2 as! String
//            }
//            else{
//                self.advice2 = "null"
//            }
//            
//        }.onDisappear(){
//            self.isLoaded = false
//        }
//    }
//    
//    func Get_URLRequest_adv_war(_ advice: String){
//        
//        let session = URLSession(configuration: .default)
//        let user_id = CurrentUserID
//        // 設定URL
//        let orgUrl = PocUrl +  "api/nilm09/adv_war?user_id=\(user_id)&advice=\(advice)"
//        let url = orgUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        var request = URLRequest(url: URL(string: url)!)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//        
//        // 接收回傳的task
//        let task = session.dataTask(with: request) {(data, response, error) in
//            do {
//                print("連線到伺服器 (Get adv_war)")
////                print(data)
////                print(response)
//                
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
////                print(json)
//                let dataDict = json?["data"] as? [String: Any]
//                let r = dataDict?["response"] as? String
//                
//                self.response = r ?? ""
//                print("response => \(self.response)")
//                
//                print("Get adv_war Pass")
//                
//                self.isLoaded = true
//            } catch {
//                print(error)
//                return
//            }
//        }
//        task.resume()
//    }
//    
//    func POST_URLRequest_adv_war(_ advice: String, _ tick : String){
//        
//        let session = URLSession(configuration: .default)
//        // 設定URL
//        let url = PocUrl + "api/nilm09/adv_war"
//        var request = URLRequest(url: URL(string: url)!)
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        
//        let user_id = CurrentUserID
//        let postData = ["user_id":user_id,"advice":advice,"tick":tick]
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
//                print("連線到伺服器 (POST adv_war)")
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
////                print(response)
////                print(json)
//                
//                Get_URLRequest_adv_war(self.advice)
//                GET_URLRequest_Forapp()
//                isClick = true
//                
//                print("POST adv_war Pass")
//            } catch {
//                print(error)
//                return
//            }
//        }
//        task.resume()
//    }
//    
//    struct ResponseData: Codable {
//        let code: Int
//        let message: String
//        let data: Data
//    }
//    
//    struct Data: Codable {
//        let user_id: String
//        let advice: String
//        let tick: String
//    }
//    
//    func GET_URLRequest_Forapp(){
//        let session = URLSession(configuration: .default)
//        let user_id = CurrentUserID
//        // 設定URL
//        let url = PocUrl +  "forapp?user_id=\(user_id)"
//        var request = URLRequest(url: URL(string: url)!)
//        
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//        // 接收回傳的task
//        let task = session.dataTask(with: request) {(data, response, error) in
//            print("連線到伺服器 (GET Forapp)")
//            //                print(response)
//            //                print(data)
//            
//            // MARK: 解析json
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                //                    let code = json?["code"] as? Int
//                //                    let message = json?["message"] as? String
//                //                        print("code: \(code)")
//                //                        print("message: \(message)")
//                
//                let dataDict = json?["app"] as? [String: Any]
////                let userId = dataDict?["user_id"] as? String
//                let user_advice_bt = dataDict?["user_advice_bt"] as? String
//                let weekly_monthly_report_bth = dataDict?["weekly_monthly_report_bth"] as? String
//                let manage_control_advice_bth = dataDict?["manage_control_advice_bth"] as? String
//                //                    print("user_id: \(userId)")
//                //                    print("user_advice_bt: \(user_advice_bt)")
//                //                    print("weekly_monthly_report_bth: \(weekly_monthly_report_bth)")
//                //                    print("manage_control_advice_bth: \(manage_control_advice_bth)")
//                
//                forapp.User_advice_bt = Int(user_advice_bt!) ?? 0
//                forapp.Weekly_monthly_report_bth = Int(weekly_monthly_report_bth!) ?? 0
//                forapp.Manage_control_advice_bth = Int(manage_control_advice_bth!) ?? 0
//                
//                //testNumber
//                //                    forapp.User_advice_bt = 8
//                print("GET Forapp Pass")
//            } catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }
//}

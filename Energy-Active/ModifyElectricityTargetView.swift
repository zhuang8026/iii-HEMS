//
//  ModifyElectricityTargetView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/11.
//

import Foundation
import SwiftUI


class ModifyElectricityTargetAlertManager : ObservableObject {
    @Published var showAlert = false
    @Published var totalTarget : Float = 100
    @Published var mouthKwh : Float = 0
    @Published var useTargetRatio : Float = 0
}

// MARK: - ModifyElectricityTargetAlert View
extension View {
    func electricityModifyElectricityTargetAlertView(showAlert: Binding <Bool>, totalTarget: Binding <Float>, mouthKwh: Binding <Float>, useTargetRatio: Binding <Float>) -> some View {
        self.modifier(ModifyElectricityTargetAlertModifier(showAlert: showAlert, totalTarget: totalTarget, mouthKwh: mouthKwh, useTargetRatio: useTargetRatio)
        )
    }
}

// MARK: - ModifyElectricityTargetAlertModifier

struct ModifyElectricityTargetAlertModifier : ViewModifier {
    @EnvironmentObject var electricityModifyElectricityTargetAlertManager : ModifyElectricityTargetAlertManager
    @Binding var showAlert: Bool
    @Binding var totalTarget:Float
    @Binding var mouthKwh:Float
    @Binding var useTargetRatio:Float
    @State var isLoaded = true
    
    @State var inputTarget:String = ""
    
    func body(content: Content) -> some View {
        
        ZStack{ content
            if showAlert {
                Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAlert = false
                    }
                
                VStack{
                    Text("本月用電目標額度設定").font(.custom("NotoSansTC-Medium", size: 24))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
                        .padding()
                    TextField("輸入目標額度", text: $inputTarget, onCommit: {
                        if let value = Float(inputTarget) {
                            self.totalTarget = round(value)
                        }
                    })
                    .font(.custom("NotoSansTC-Medium", size: 16))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .padding(2)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("度").font(.custom("NotoSansTC-Medium", size: 16))
                                .padding(10)
                        }
                    ).padding()
                    
                    HStack{
                        Button {
                            if (isLoaded) {
                                isLoaded = false
                                PATCH_URLRequest_target(inputTarget)
                            }
                        } label: {
                            Spacer()
                            Text("儲存")
                                .font(.custom("NotoSansTC-Medium", size: 16))
                                .foregroundColor(AlertSureButtonColor)
                            Spacer()
                        }
                        .padding(10)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .background(AlertSureButtonBackgroundColor)
                        .cornerRadius(10)
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                        .disabled(inputTarget == "")
                    }
                    .padding()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 12)
                .shadow(radius: 1, x: 2, y: 2)
                
                
                if(!self.isLoaded){
                    Color.init(hex: "#f3f3f3", alpha: 0.4)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
                        .scaleEffect(2)
                }
            }
        }
        .onChange(of: showAlert) { value in
            if value {
                inputTarget = String(format: "%.0f", electricityModifyElectricityTargetAlertManager.totalTarget)
            }
        }
    }
    
    func PATCH_URLRequest_target(_ target : String){
     
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "target", value: target),
        ]
        let query = components.percentEncodedQuery ?? ""
        let data = Data(query.utf8)
        
        
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token")!
        let url = PocUrl + "api/main/trace/target"
        var request = URLRequest(url: URL(string: url)!)

        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        request.httpBody = data
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (PATCH target)")
            //                print(response)
            //                print(data)
            
            //                // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //                    print(json)
                if(code == 200){
                    //                        print(json)
                    // MARK: 等待
                    Thread.sleep(forTimeInterval: 0.5)
                    
                    GET_URLRequest_Current_Mon_SetTarget()
                    print("PATCH target Pass")
                    
                }
                //                    else if(code == 4002){
                //                        //back to login
                //                        loginflag = true
                //                    }
                //                    else{
                //                        //back to login
                //                        loginflag = true
                //                    }
                else{
                    print("PATCH target fail")
                    isLoaded = true
                    showAlert = false
                }
            } catch {
                print("PATCH target fail")
                print(error)
                
                isLoaded = true
                showAlert = false
            }
        }
        task.resume()
    }
    
    func GET_URLRequest_Current_Mon_SetTarget(){
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token")!
        let url = PocUrl + "api/main/trace/current-mon"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET current-mon SetTarget)")
            
            //                // MARK: 解析json
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //                    let message = json?["message"] as? String
                //                    print("code: \(code)")
                //                    print("message: \(message)")
                if(code == 200){
                    let dataDict = json?["data"] as? [String: Any]
                    //用電評論
                    //                        let predResult = dataDict?["predResult"] as? String
                    //本月設定用電目標
                    let target = dataDict?["target"] as? Int
                    //本月累積電量
                    let accumKwh = dataDict?["accumKwh"] as? Float
                    print("target(本月設定用電目標): \(String(describing: target))")
                    print("accumKwh(本月累積電量): \(String(describing: accumKwh))")
                    
                    //本月設定用電目標
                    self.totalTarget = Float(target!).rounded()
                    //本月累積電量
                    self.mouthKwh = accumKwh ?? 1
                    //計算累積用電與預期目標比例
                    self.useTargetRatio = self.mouthKwh / (self.totalTarget * 1.2)
                    
                    isLoaded = true
                    showAlert = false
                    
                    print("GET current-mon SetTarget pass")
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
}

// 舊版
//struct ModifyElectricityTargetView: View {
//    @Binding var showView: Bool    
//    @Binding var totalTarget:Float
//    @Binding var mouthKwh:Float
//    @Binding var useTargetRatio:Float
//    @State var isLoaded = true
//    
//    @State var inputTarget:String = ""
//    var body: some View {
//        ZStack{
//            
////            Color.init(hex: "#e0e0e0", alpha: 0.9)
//            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showView = false
//                }
//            
//            VStack{
//                Text("本月用電目標額度設定").font(.custom("NotoSansTC-Medium", size: 24))
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
//                    .padding()
////                Divider().padding(.horizontal)
//                
////                TextField("輸入目標額度", text: $inputTarget)
////                TextField(String(format: "%.0f", self.totalTarget), text: $inputTarget)
//                TextField("輸入目標額度", text: $inputTarget, onCommit: {
//                    if let value = Float(inputTarget) {
//                        totalTarget = round(value)
//                    }
//                })
//                    .font(.custom("NotoSansTC-Medium", size: 16))
//                    .textFieldStyle(.roundedBorder)
//                    .keyboardType(.numberPad)
//                    .padding(2)
//                    .overlay(
//                        HStack {
//                            Spacer()
//                            Text("度").font(.custom("NotoSansTC-Medium", size: 16))
//                                .padding(10)
//                        }
//                    )
//                    .padding()
//                
//                
//                HStack{
//                    
//                    Button {
////                        print("確認")
//                        if (isLoaded)
//                        {
//                            isLoaded = false
//                            PATCH_URLRequest_target(inputTarget)
//                        }
//                    } label: {
//                        
//                        Spacer()
//                        
//                        Text("儲存")
//                            .font(.custom("NotoSansTC-Medium", size: 16))
//                            .foregroundColor(AlertSureButtonColor)
//                                                                                
//                        Spacer()
//                        
//                    }
//                    .padding(10)
//                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                    .background(AlertSureButtonBackgroundColor)
//                    .cornerRadius(10)
//                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
//                    .disabled(inputTarget == "")
//                }
//                .padding()
//            }
//            .frame(minWidth: 0, maxWidth: .infinity)
//            .background(Color.white)
//            .cornerRadius(10)
//            .padding(.horizontal, 12)
//            .shadow(radius: 1, x: 2, y: 2)
//            
//            
//            if(!self.isLoaded){                
//                Color.init(hex: "#f3f3f3", alpha: 0.4)
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
//                    .scaleEffect(2)
//            }
//        }.onAppear {
//            inputTarget = String(format: "%.0f", totalTarget)
//        }
//    }
//    
//    func PATCH_URLRequest_target(_ target : String){
//     
//        var components = URLComponents()
//        components.queryItems = [
//            URLQueryItem(name: "target", value: target),
//        ]
//        let query = components.percentEncodedQuery ?? ""
//        let data = Data(query.utf8)
//        
//        
//        let session = URLSession(configuration: .default)
//        let token = UserDefaults.standard.string(forKey: "access_token")!
//        let url = PocUrl + "api/main/trace/target"
//        var request = URLRequest(url: URL(string: url)!)
//
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.httpMethod = "PATCH"
//        request.httpBody = data
//        // 接收回傳的task
//        let task = session.dataTask(with: request) {(data, response, error) in
//            print("連線到伺服器 (PATCH target)")
//            //                print(response)
//            //                print(data)
//            
//            //                // MARK: 解析json
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                let code : Int = json?["code"] as? Int ?? 0
//                //                    print(json)
//                if(code == 200){
//                    //                        print(json)
//                    // MARK: 等待
//                    Thread.sleep(forTimeInterval: 0.5)
//                    
//                    GET_URLRequest_Current_Mon_SetTarget()
//                    print("PATCH target Pass")
//                    
//                }
//                //                    else if(code == 4002){
//                //                        //back to login
//                //                        loginflag = true
//                //                    }
//                //                    else{
//                //                        //back to login
//                //                        loginflag = true
//                //                    }
//                else{
//                    print("PATCH target fail")
//                    isLoaded = true
//                    showView = false
//                }
//            } catch {
//                print("PATCH target fail")
//                print(error)
//                
//                isLoaded = true
//                showView = false
//            }
//        }
//        task.resume()
//    }
//    
//    func GET_URLRequest_Current_Mon_SetTarget(){
//        let session = URLSession(configuration: .default)
//        let token = UserDefaults.standard.string(forKey: "access_token")!
//        let url = PocUrl + "api/main/trace/current-mon"
//        var request = URLRequest(url: URL(string: url)!)
//        
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.httpMethod = "GET"
//        // 接收回傳的task
//        let task = session.dataTask(with: request) {(data, response, error) in
//            print("連線到伺服器 (GET current-mon SetTarget)")
//            
//            //                // MARK: 解析json
//            do {
//                
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                let code : Int = json?["code"] as? Int ?? 0
//                //                    let message = json?["message"] as? String
//                //                    print("code: \(code)")
//                //                    print("message: \(message)")
//                if(code == 200){
//                    let dataDict = json?["data"] as? [String: Any]
//                    //用電評論
//                    //                        let predResult = dataDict?["predResult"] as? String
//                    //本月設定用電目標
//                    let target = dataDict?["target"] as? Int
//                    //本月累積電量
//                    let accumKwh = dataDict?["accumKwh"] as? Float
//                    print("target(本月設定用電目標): \(String(describing: target))")
//                    print("accumKwh(本月累積電量): \(String(describing: accumKwh))")
//                    
//                    //本月設定用電目標
//                    self.totalTarget = Float(target!).rounded()
//                    //本月累積電量
//                    self.mouthKwh = accumKwh ?? 1
//                    //計算累積用電與預期目標比例
//                    self.useTargetRatio = self.mouthKwh / (self.totalTarget * 1.2)
//                    
//                    isLoaded = true
//                    showView = false
//                    
//                    print("GET current-mon SetTarget pass")
//                }
//            } catch {
//                print(error)
//            }
//        }
//        task.resume()
//        
//    }
//}

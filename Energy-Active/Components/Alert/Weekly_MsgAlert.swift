//
//  Weekly_MsgAlert.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/19.
//

import Foundation
import SwiftUI

// MARK: - Weekly_MsgAlert View
extension View {
    func electricityWeekly_MsgAlertView(showAlert: Binding <Bool>, performance: String, weekly_advice: String) -> some View {
        self.modifier(Weekly_MsgAlertModifierModifier(showAlert: showAlert, performance: performance, weekly_advice: weekly_advice)
        )
    }
}


// MARK: - Weekly_MsgAlertModifier

struct Weekly_MsgAlertModifierModifier : ViewModifier {

    @EnvironmentObject var electricityElectricityTrackingAlertManager : ElectricityTrackingAlertManager
    @Binding var showAlert: Bool
    
    @State var performance:String
    @State var weekly_advice:String
    
    @State var isClick = false
    @State var isLoaded = false
    
    
    func body(content: Content) -> some View {
        
        ZStack{ content
            if showAlert {
                Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAlert = false
                    }
                if(isLoaded)
                {
                    VStack{
                        VStack {
                            Text("用電提醒").font(.custom("NotoSansTC-Medium", size: 24)).padding(.top)
                            
                            ScrollView{
                                HStack{
                                    Image("icon-power")
                                        .font(.system(size: 8, weight: .bold))
                                    Text("節電小秘訣").frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                                
                                if(performance != "")
                                {
                                    Text("1. " + performance).font(.custom("NotoSansTC-Medium", size: 16))
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.vertical)
                                }
                                
                                if(weekly_advice != ""){
                                    Text("2. " + weekly_advice).font(.custom("NotoSansTC-Medium", size: 16))
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                            }
                            .font(.custom("NotoSansTC-Medium", size: 16))
                            .foregroundColor(Color.init(hex: "#76839c", alpha: 1.0))
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.init(hex: "#ebeefa", alpha: 1.0))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.init(hex: "#f3f3f3", alpha: 1.0) , lineWidth: 2)
                            ).padding(.horizontal)
                                .padding(.top)
                            
                            Spacer()
                            
                            Group{
                                if(isClick){
                                    
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
                                    Group{
                                        Text("上述建議是否對您有幫助？").font(.custom("NotoSansTC-Medium", size: 16))
                                        HStack {
                                            Button(action: {
                                                let lastMonday = getLastMonday()
                                                POST_URLRequest_weekly_msg(lastMonday, "0")
                                                isClick = true
                                                //                                        print("test No")
                                                
                                            }, label: {
                                                Text("否")
                                                    .font(.custom("NotoSansTC-Medium", size: 16))
                                                    .foregroundColor(AlertCancelButtonColor)
                                                    .padding(10)
                                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                    .background(AlertCancelButtonBackgroundColor)
                                                    .cornerRadius(10)
                                            })
                                            .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                                            
                                            Button(action: {
                                                let lastMonday = getLastMonday()
                                                POST_URLRequest_weekly_msg(lastMonday, "1")
                                                isClick = true
                                                //                                        print("test Yes")
                                                
                                            }, label: {
                                                Text("是")
                                                    .font(.custom("NotoSansTC-Medium", size: 16))
                                                    .foregroundColor(AlertSureButtonColor)
                                                    .padding(10)
                                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                    .background(AlertSureButtonBackgroundColor)
                                                    .cornerRadius(10)
                                            })
                                            .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                                        }
                                        .padding(.top, 0)
                                        .padding([.leading, .trailing, .bottom])
                                    }
                                }
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.5)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 12)
                    }
                }
            }
        }.onChange(of: showAlert) { value in
            if (value && !electricityElectricityTrackingAlertManager.showContinuousLoginAlert){
                print("開啟 Weekly_MsgAlert 頁面")
                // MARK: 等待這裡開始先刷新界面必備資料
                Thread.sleep(forTimeInterval: 0.5)
                self.isLoaded = true
            }
        }
        // MARK: 若關閉每日登入視窗時也偵測
        .onChange(of: electricityElectricityTrackingAlertManager.showContinuousLoginAlert) { value in
            if (!value && electricityElectricityTrackingAlertManager.showWeekly_MsgAlert){
                print("開啟 Weekly_MsgAlert 頁面")
                // MARK: 等待這裡開始先刷新界面必備資料
                Thread.sleep(forTimeInterval: 0.5)
                self.isLoaded = true
            }
        }
        .onDisappear(){
            self.isLoaded = false
        }
    }
    
    func POST_URLRequest_weekly_msg(_ startDate : String, _ tick : String){
     
        print("POST startDate : \(startDate)")
        let session = URLSession(configuration: .default)
        // 設定URL
        let url = PocUrl + "/api/nilm09/weekly_msg"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let user_id = CurrentUserID
        let postData = ["user_id":user_id,"start_date":startDate,"tick":tick]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
            request.httpBody = jsonData
        } catch {

        }
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
                print("連線到伺服器 (POST weekly_msg)")
                
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//                print(json)
                
                print("POST weekly_msg Pass")
        }
        task.resume()
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
}



//struct Weekly_MsgAlert: View {
//
//    @Binding var showAlert: Bool
//    
//    @State var performance:String
//    @State var weekly_advice:String
//    
//    @State var isClick = false
//    @State var isLoaded = false
//    
//    
//    var body: some View {
//        
//        ZStack{
//            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showAlert = false
//                }
//            if(isLoaded)
//            {
//                VStack{
//                    VStack {
//                        Text("用電提醒").font(.custom("NotoSansTC-Medium", size: 24)).padding(.top)
//
//                        ScrollView{
//                            HStack{
//                                Image("icon-power")
//                                    .font(.system(size: 8, weight: .bold))
//                                Text("節電小秘訣").frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            }
//                            
//                            if(performance != "")
//                            {
//                                Text("1. " + performance).font(.custom("NotoSansTC-Medium", size: 16))
//                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                                    .fixedSize(horizontal: false, vertical: true)
//                                    .padding(.vertical)
//                            }
//                            
//                            if(weekly_advice != ""){
//                                Text("2. " + weekly_advice).font(.custom("NotoSansTC-Medium", size: 16))
//                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                                    .fixedSize(horizontal: false, vertical: true)
//                            }
//
//                        }
//                        .font(.custom("NotoSansTC-Medium", size: 16))
//                        .foregroundColor(Color.init(hex: "#76839c", alpha: 1.0))
//                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                        .padding()
//                        .background(Color.init(hex: "#ebeefa", alpha: 1.0))
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.init(hex: "#f3f3f3", alpha: 1.0) , lineWidth: 2)
//                        ).padding(.horizontal)
//                        .padding(.top)
//                        
//                        Spacer()
//                        
//                        Group{
//                            if(isClick){
//                                
//                                Text("謝謝您的反饋")
//                                    .font(.custom("NotoSansTC-Medium", size: 16))
//                                    .foregroundColor(AlertCancelButtonColor)
//                                    .padding(5)
//                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                                    .cornerRadius(10)
//                                    .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(AlertCancelButtonColor, lineWidth: 2)
//                                    )
//                                    .padding()
//                            }
//                            else{
//                                Group{
//                                    Text("上述建議是否對您有幫助？").font(.custom("NotoSansTC-Medium", size: 16))
//                                    HStack {
//                                        Button(action: {
//                                            let lastMonday = getLastMonday()
//                                            POST_URLRequest_weekly_msg(lastMonday, "0")
//                                            isClick = true
//                                            //                                        print("test No")
//                                            
//                                        }, label: {
//                                            Text("否")
//                                                .font(.custom("NotoSansTC-Medium", size: 16))
//                                                .foregroundColor(AlertCancelButtonColor)
//                                                .padding(10)
//                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                                                .background(AlertCancelButtonBackgroundColor)
//                                                .cornerRadius(10)
//                                        })
//                                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
//                                        
//                                        Button(action: {
//                                            let lastMonday = getLastMonday()
//                                            POST_URLRequest_weekly_msg(lastMonday, "1")
//                                            isClick = true
//                                            //                                        print("test Yes")
//                                            
//                                        }, label: {
//                                            Text("是")
//                                                .font(.custom("NotoSansTC-Medium", size: 16))
//                                                .foregroundColor(AlertSureButtonColor)
//                                                .padding(10)
//                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                                                .background(AlertSureButtonBackgroundColor)
//                                                .cornerRadius(10)
//                                        })
//                                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
//                                    }
//                                    .padding(.top, 0)
//                                    .padding([.leading, .trailing, .bottom])
//                                }
//                            }
//                        }
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.5)
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 12)
//                }
//            }
//        }.onAppear{
//            print("開啟 Weekly_MsgAlert 頁面")
//            // MARK: 從這裡開始先刷新界面必備資料
//     
//            // MARK: 等待
//            Thread.sleep(forTimeInterval: 0.5)
//            self.isLoaded = true
//            
//        }.onDisappear(){
//            self.isLoaded = false
//        }
//    }
//    
//    func POST_URLRequest_weekly_msg(_ startDate : String, _ tick : String){
//     
//        print("POST startDate : \(startDate)")
//        let session = URLSession(configuration: .default)
//        // 設定URL
//        let url = PocUrl + "/api/nilm09/weekly_msg"
//        var request = URLRequest(url: URL(string: url)!)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        
//        let user_id = CurrentUserID
//        let postData = ["user_id":user_id,"start_date":startDate,"tick":tick]
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
//            request.httpBody = jsonData
//        } catch {
//
//        }
//        
//        // 接收回傳的task
//        let task = session.dataTask(with: request) {(data, response, error) in
//                print("連線到伺服器 (POST weekly_msg)")
//                
////                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
////                print(json)
//                
//                print("POST weekly_msg Pass")
//        }
//        task.resume()
//    }
//    
//    func getLastMonday() -> String {
//        let calendar = Calendar.current
//        let today = Date()
//        let weekday = calendar.component(.weekday, from: today)
//        let daysToMonday = (weekday + 5) % 7  + 7
//        var lastMonday = ""
//        
//        //取得上週一的日期
//        if let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today) {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
////            let mondayString = formatter.string(from: monday)
////            print("星期一的日期是：\(mondayString)")
//            lastMonday = formatter.string(from: monday)
//        }            
//        
//        return lastMonday
//            
//    }
//}

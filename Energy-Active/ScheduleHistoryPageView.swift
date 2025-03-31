//
//  ScheduleHistoryPageView.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/13.
//

import SwiftUI
import UIKit


struct ScheduleHistoryPageView: View {
        
    @Binding var loginflag : Bool
    @Binding var deviceId : String
    @Binding var total_pages : Int
    @Binding var current_page : Int
    @Binding var page_show_count : Int
    @Binding var isDataEmpty : Bool
//    @State var isLoaded = false
    @Binding var isLoaded : Bool
    
    @State private var scrollOffset: CGFloat = 0
    @State var cloudRemoteSchedulesHistoryPageArray = [CloudRemoteSchedulesHistoryPageInfo]()
    
    var body: some View {        
        ZStack{
            if(cloudRemoteSchedulesHistoryPageArray.count > 0 && isLoaded) {
                ScrollView(.horizontal, showsIndicators: true)
                {
                    HStack (spacing: 0){
                        Text("日期").frame(width: 100, height: 25, alignment: .leading).padding(.leading, 7)
                        Text("時間").frame(width: 85, height: 25)
                        Text("週期").frame(width: 85, height: 25)
                        Text("動作").frame(width: 85, height: 25)
                        Text("執行狀態").frame(width: 85, height: 25, alignment: .trailing).padding(.trailing, 7)
                    }.font(.custom("NotoSansTC-Medium", size: 18))
                        .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                    
                    VStack (spacing: 3){
                        ScrollView (.vertical, showsIndicators: true){
                            ForEach(0..<cloudRemoteSchedulesHistoryPageArray.count, id: \.self){  index in
                                HStack (spacing: 0){
                                    Text(getDateString(cloudRemoteSchedulesHistoryPageArray[index].trigger_time ?? "N/A")).frame(width: 100, height: 25, alignment: .leading).padding(.leading, 7)
                                    Text(getTimeString(cloudRemoteSchedulesHistoryPageArray[index].trigger_time ?? "N/A")).frame(width: 85, height: 25)
                                    Text(getFrequencyString(cloudRemoteSchedulesHistoryPageArray[index].trigger_time ?? "N/A")).frame(width: 85, height: 25)
                                    Text(getActionString(cloudRemoteSchedulesHistoryPageArray[index].action ?? "N/A")).frame(width: 85, height: 25)
                                    Text(getResultString(cloudRemoteSchedulesHistoryPageArray[index].result ?? "N/A")).frame(width: 85, height: 25, alignment: .trailing).padding(.trailing, 7)
                                        .foregroundColor(cloudRemoteSchedulesHistoryPageArray[index].result ?? "N/A" == "0" ?
                                                         GreenCustomizeColor :
                                                            Color(red: 1.0, green: 96.0 / 255.0, blue: 96.0 / 255.0))
                                    
                                    
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
                .background(cloudRemoteSchedulesHistoryPageArray.count > 0 ? .clear : Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                .cornerRadius(5.0)
                .padding(.horizontal,25).padding(.top,33)
            }
        }
        .onAppear{
            print("開啟排程管理歷史列表(ScheduleHistoryPage)頁面")
            isLoaded = false
//            print(" page_show_count = \(page_show_count)")
//            print("送出的頁碼(當前/總共) = (\(self.current_page)/\(self.total_pages))")
            GET_URLRequest_CloidRemote_Schedule_HistoryPage(self.deviceId, self.current_page, self.page_show_count)
            
        }
        .onChange(of: self.current_page){ value in
            print("刷新排程管理歷史列表(ScheduleHistoryPage)頁面")
            isLoaded = false
//            print("送出的頁碼(當前/總共) = (\(self.current_page)/\(self.total_pages))")
            GET_URLRequest_CloidRemote_Schedule_HistoryPage(self.deviceId, self.current_page, self.page_show_count)
            
        }
    }
    
    // MARK: - 取得排程管理歷史列表
    func GET_URLRequest_CloidRemote_Schedule_HistoryPage(_ device_Id : String, _ page : Int, _ size : Int) {
                
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let url = PocUrl + "api/main/cloud-remote/schedule/history-page?deviceId=\(device_Id)&page=\(page)&size=\(size)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET cloud-remote schedule history-page)")
            //                print(response)
            //                print(data)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //                let message = json?["message"] as? String
                //                    print("code: \(code)")
                //                    print("message: \(message)")
                
                if(code == 200){
                    // MARK: 取得排程管理歷史列表內容
                    if let dataDict = json?["data"] as? [String: Any], let _result = dataDict["logs"] as? [[String: Any]] {
                        let current_page = dataDict["current_page"] as? Int ?? 1
                        let total_pages = dataDict["total_pages"] as? Int ?? 10
                        let total_count = dataDict["total_count"] as? Int ?? 10
                        //                            let limit = dataDict["limit"] as? Int ?? 10
                        //                            let log_count = dataDict["log_count"] as? Int ?? 10
                        
                        self.current_page = current_page
                        self.total_pages =  total_pages
                        print("取得頁碼(當前/總計) : \(self.current_page) / \(self.total_pages) => 項目總個數 : \(total_count)" )
                        
                        //先清除舊的
                        cloudRemoteSchedulesHistoryPageArray = [CloudRemoteSchedulesHistoryPageInfo]()
                        
                        for item in _result{
                            
                            var d : CloudRemoteSchedulesHistoryPageInfo = CloudRemoteSchedulesHistoryPageInfo()
                            d.cmdsn = item["cmdsn"] as? String
                            d.dev_id = item["dev_id"] as? String
                            d.action = item["action"] as? String
                            d.trigger_time = item["trigger_time"] as? String
                            d.result = item["result"] as? String
                            
                            //                                print("cmdsn : " + (d.cmdsn ?? "null"))
                            //                                print("dev_id : " + (d.dev_id ?? "null"))
                            //                                print("action : " + (d.action ?? "null"))
                            //                                print("trigger_time : " + (d.trigger_time ?? "null"))
                            //                                print("result : " + (d.result ?? "null"))
                            
                            // MARK: 寫入UI
                            cloudRemoteSchedulesHistoryPageArray.append(d)
                        }
                        isDataEmpty = false
                    }
                    
                    if(cloudRemoteSchedulesHistoryPageArray.count == 0){
                        isDataEmpty = true
                    }
                    isLoaded = true
                    
                    print("GET cloud-remote schedule history-page psas")
                }
                else {//if(code == 4002){
                    //back to login
                    print("Back to login view,error code = ", code)
                    loginflag = true
                }
                //                    }
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }

    func getDateString(_ action : String) ->String {
        
        let timestamp = (TimeInterval(action) ?? 0) / 1000
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let formattedDate = dateFormatter.string(from: date)
                
        return formattedDate
    }
    
    func getTimeString(_ action : String) ->String {
        let timestamp = (TimeInterval(action) ?? 0) / 1000
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
    
    func getFrequencyString(_ action : String) ->String {
        let timestamp = (TimeInterval(action) ?? 0) / 1000
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: date)
        var weekDayName = dateFormatter.weekdaySymbols[weekDay - 1]
        
        switch weekDay {
        case 1:
            weekDayName = "日"
        case 2:
            weekDayName = "一"
        case 3:
            weekDayName = "二"
        case 4:
            weekDayName = "三"
        case 5:
            weekDayName = "四"
        case 6:
            weekDayName = "五"
        case 7:
            weekDayName = "六"
        default:
            weekDayName = "N/A"
        }
        
        return weekDayName
    }
    
    func getActionString(_ action : String) ->String {
        if action == "on"{
            return "啟動"
        }
        else{
            return "關閉"
        }
    }
    
    func getResultString(_ action : String) ->String {
        if action == "0"{
            return "成功"
        }
        else {
            return "失敗"
        }
    }
}


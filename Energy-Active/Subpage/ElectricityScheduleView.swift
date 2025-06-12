//
//  ElectricityScheduleView.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/10.
//

import SwiftUI



// MARK: - 管理用電-取得排程管理列表

extension View {
    
    func environmentElectricityScheduleView(loginflag: Binding <Bool>, showAlert: Binding <Bool>, isHistoryPage: Binding <Bool>) -> some View {
        self.modifier(environmentElectricityScheduleAlert(loginflag: loginflag, showAlert: showAlert, isHistoryPage: isHistoryPage)
        )
    }
}

struct environmentElectricityScheduleAlert : ViewModifier {
        
    @EnvironmentObject var electricityScheduleManager : ElectricityScheduleManager
    @EnvironmentObject var createReviseScheduleManager : CreateReviseScheduleManager
    @EnvironmentObject var electricityCustomDeleteAlertManager : CustomDeleteAlertManager
    
    @Binding var loginflag:Bool
    @Binding var showAlert: Bool
    @Binding var isHistoryPage: Bool
    @State var isClick = false
//    @State var isLoaded = false
    
    @State var historyPageIsLoaded = false
    @State var isDataEmpty = true
    @State var total_pages = 5
    @State var page_show_count = 10
    @State var current_page = 1
    
    func body(content: Content) -> some View {
    
        ZStack { content
            if showAlert {
                showElectricityScheduleAlert()
            }
        }
    }
}

extension environmentElectricityScheduleAlert {

    func showElectricityScheduleAlert() -> some View  {
        ZStack{
            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showAlert = false
                }
            
            VStack (spacing: 0){                
                Group{
                    ZStack{
                        Text("\(electricityScheduleManager.deviceName)排程管理").font(.custom("NotoSansTC-Medium", size: 24))
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
                    
                    HStack {
                        Button(action: {
                            print("Button not isHistoryPage")
                            Task{
                                self.isDataEmpty = true
                                self.isHistoryPage = false
                            }
                        }, label: {
                            Text("排程管理").font(.custom("NotoSansTC-Medium", size: 20))
                                .foregroundColor(!isHistoryPage ? Color(white: 1.0) :
                                                    DarkGrayCustomizeColor)
                                .frame(width: 144.0, height: 50.0)
                                .background(!isHistoryPage ? GreenCustomizeColor : GreyCustomizeColor)
                                .cornerRadius(40.0)
                        }).disabled(!isHistoryPage)
                        
                        Spacer()
                        
                        Button(action: {
                            print("Button isHistoryPage")
                            self.current_page = 1
                            self.isDataEmpty = true
                            self.isHistoryPage = true
                        }, label: {
                            Text("歷史列表").font(.custom("NotoSansTC-Medium", size: 20))
                                .foregroundColor(isHistoryPage ? Color(white: 1.0) : DarkGrayCustomizeColor)
                                .frame(width: 144.0, height: 50.0)
                                .background(isHistoryPage ? GreenCustomizeColor : Color(red: 241.0 / 255.0, green: 243.0 / 255.0, blue: 252.0 / 255.0))
                                .cornerRadius(40.0)
                        }).disabled(isHistoryPage)
                    }.padding(.horizontal, 25).padding(.top, 14)
                }
                
                if isHistoryPage
                {
                    // MARK: - 排程管理歷史列表
                    Group{
                        VStack{
                            ScheduleHistoryPageView(loginflag: $loginflag, deviceId: $electricityScheduleManager.deviceId, total_pages: $total_pages, current_page: $current_page, page_show_count: $page_show_count, isDataEmpty: $isDataEmpty, isLoaded: $historyPageIsLoaded)

                            if(!isDataEmpty){
                                PaginationView(currentPage: $current_page, isLoaded: $historyPageIsLoaded, totalPages: total_pages, maxDisplayedPages: 5)
                                    .frame(height: 47).padding(.top, 8)
                            }
                        }
                    }
                }
                else{
                    // MARK: - 排程管理列表
                    Group{
                        VStack{
                            SchedulePageView(loginflag: $loginflag, showAlert: $showAlert, deviceId: $electricityScheduleManager.deviceId, isDataEmpty: $isDataEmpty)
                        }
                    }
                }
                
                
                Button(action: {
                    print("Button Create new schedule")
                    
                    //MARK: 初始化新增排程內容
                    createReviseScheduleManager.isCreateSchedule = true
                    createReviseScheduleManager.deviceId = electricityScheduleManager.deviceId
                    createReviseScheduleManager.currentSchedDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
                    createReviseScheduleManager.schedFreq = "once"
                    createReviseScheduleManager.action = "on"
                    createReviseScheduleManager.weekOnOffArray = [false, false, false, false, false, false, false]
                    createReviseScheduleManager.showAlert = true
                }, label: {
                    Text("新增排程").font(.custom("NotoSansTC-Medium", size: 20))
                        .foregroundColor(Color(white: 1.0))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 52.0)
                        .background(GreenCustomizeColor)
                        .cornerRadius(40.0)
                        .padding(.horizontal, 25)
                        .padding(.top, 26).padding(.bottom, 12)
                })
                
                
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, 12)
            
        }.onAppear{
            print("開啟 Electricity Schedule 頁面")
        }
    }
    
    //MARK: - String 轉 Data
    func timeStringToDate(_ dateStr:String) ->Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: dateStr)
        return date!
    }    
}

class ElectricityScheduleManager : ObservableObject {
    
    @Published var showAlert = false
    @Published var deviceId : String = "N/A"
    @Published var deviceName : String = "N/A"
    @Published var isHistoryPage = false
}

struct CloudRemoteSchedulesInfo {
    var trigger_name : String?
    var job_detail_name : String?
    var dev_id : String?
    var action : String?
    var sched_freq : String?
    var sched_date : String?
    var sched_week : String?
    var sched_time : String?
    var sched_desc : String?
    var timezone : String?
    var last_updated : String?
    var enable : String?
}

struct CloudRemoteSchedulesHistoryPageInfo {
    var cmdsn : String?
    var dev_id : String?
    var action : String?
    var trigger_time : String?
    var result : String?
}


// MARK: - 頁碼功能
struct PaginationView: View {
    @Binding var currentPage: Int
    @Binding var isLoaded : Bool
    let totalPages: Int
    let maxDisplayedPages: Int

    var body: some View {
        HStack(spacing: 0) {
            if(currentPage > 1)
            {
                // 上一頁
                Button(action: {
                    withAnimation {
                        if currentPage > 1 {
                            currentPage -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .padding(5)
                        .frame(width: 40.0, height: 48.0)
                        .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                        .foregroundColor(Color(white: 112.0 / 255.0))
                    
                }
//                .disabled(currentPage == 1) // 第一頁禁用
                .disabled(!isLoaded)
            }
            
            // 頁碼
            ForEach(pageRange(), id: \.self) { page in
                Button(action: {
                    withAnimation {
                        currentPage = page
                    }
                    
                }) {
                    Text("\(page)").font(.custom("NotoSansTC-Bold", size: 20.0))
                        .foregroundColor(page == currentPage ? Color(white: 1.0) : Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                        .padding(5)
                        .frame(width: 40.0, height: 48.0)
                        .background(page == currentPage ? GreenCustomizeColor :
                                        Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                }
                .disabled(!isLoaded)
            }
            
            if (currentPage != totalPages)
            {
                // 下一頁
                Button(action: {
                    withAnimation {
                        if currentPage < totalPages {
                            currentPage += 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .padding(5)
                        .frame(width: 40.0, height: 48.0)
                        .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
                        .foregroundColor(Color(white: 112.0 / 255.0))
                    
                }
//                .disabled(currentPage == totalPages) // 最後一頁
                .disabled(!isLoaded)
            }
        }
        .padding(.horizontal, 26)
    }

    // 計算顯示頁碼範圍
    private func pageRange() -> ClosedRange<Int> {
        let lowerBound = max(currentPage - 2, 1)
        let upperBound = min(currentPage + 2, totalPages)
        return lowerBound...upperBound
    }

}


// MARK: - 頁碼功能（原規格）
//struct PaginationView: View {
//    @Binding var currentPage: Int
//    let totalPages: Int
//    let maxDisplayedPages: Int
//
//    var body: some View {
//        HStack(spacing: 10) {
//            // 上一頁
//            Button(action: {
//                if currentPage > 1 {
//                    currentPage -= 1
//                }
//            }) {
//                Image(systemName: "chevron.left")
//                    .font(.headline)
//                    .padding(5)
//                    .frame(width: 25.0, height: 47.0)
//                    .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
//                    .foregroundColor(Color(white: 112.0 / 255.0))
//                    
//                    
//            }
//            .disabled(currentPage == 1) // 第一頁禁用
//
//            Spacer(minLength: 0)
//            
//            // 頁碼
//            ForEach(pageRange(), id: \.self) { page in
//                Button(action: {
//                    currentPage = page
//                }) {
//                    Text("\(page)").font(.custom("NotoSansTC-Bold", size: 20.0))
//                        .foregroundColor(page == currentPage ? Color(white: 1.0) : Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
//                        .padding(5)
//                        .frame(width: 25.0, height: 47.0)
//                        .background(page == currentPage ? GreenCustomizeColor :
//                                        Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
//                }
//            }
//            
//            Spacer(minLength: 0)
//
//            // 下一頁
//            Button(action: {
//                if currentPage < totalPages {
//                    currentPage += 1
//                }
//            }) {
//                Image(systemName: "chevron.right")
//                    .font(.headline)
//                    .padding(5)
//                    .frame(width: 25.0, height: 47.0)
//                    .background(Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0))
//                    .foregroundColor(Color(white: 112.0 / 255.0))
//                    
//            }
//            .disabled(currentPage == totalPages) // 最後一頁
//        }
//        .padding(.horizontal, 26)
//    }
//
//    // 計算顯示頁碼範圍
//    private func pageRange() -> ClosedRange<Int> {
//        let midPoint = maxDisplayedPages / 2
//        let lowerBound = max(currentPage - midPoint, 1)
//        let upperBound = min(lowerBound + maxDisplayedPages - 1, totalPages)
//        return lowerBound...upperBound
//    }
//}

//
//  ContinuousLoginAlert.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/19.
//

import Foundation
import SwiftUI


// MARK: - ContinuousLoginAlert View
extension View {
    func electricityContinuousLoginAlertView(showAlert: Binding <Bool>, loginday: Int) -> some View {
        self.modifier(ContinuousLoginAlertModifier(showAlert: showAlert, loginday: loginday)
        )
    }
}

// MARK: - ContinuousLoginAlertModifier

struct ContinuousLoginAlertModifier : ViewModifier {

    @EnvironmentObject var electricityElectricityTrackingAlertManager : ElectricityTrackingAlertManager
    
    @Binding var showAlert: Bool
    
    @State var loginday:Int
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
                            Text("累計簽到任務").font(.custom("NotoSansTC-Medium", size: 24))
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Divider().padding(.horizontal)
                            
                            VStack{
                                Text("已經連續登入 \(loginday) 天\n請持續努力喔!!")
                                    .font(.custom("NotoSansTC-Medium", size: 16))
                                    .foregroundColor(Color.init(hex: "#76839c", alpha: 1.0))
                                //                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.init(hex: "#ebeefa", alpha: 1.0))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.init(hex: "#f3f3f3", alpha: 1.0) , lineWidth: 2)
                            ).padding(.horizontal)
                                .padding(.top)
                            
                            Button(action: {
                                showAlert = false
                            }, label: {
                                Text("確定")
                                    .font(.custom("NotoSansTC-Medium", size: 16))
                                    .foregroundColor(AlertSureButtonColor)
                                    .padding(10)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .background(AlertSureButtonBackgroundColor)
                                    .cornerRadius(10)
                            })
                            .padding()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.4)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 12)
                    }
                }
            }
        }.onAppear{
            print("開啟 ContinuousLoginAlert 頁面")
            // MARK: 從這裡開始先刷新界面必備資料
            
            // MARK: 等待
            Thread.sleep(forTimeInterval: 0.5)
            self.isLoaded = true
            
        }.onDisappear(){
            self.isLoaded = false
        }
    }
}

//struct ContinuousLoginAlert: View {
//
//    @Binding var showAlert: Bool
//    
//    @State var loginday:Int
//    @State var isLoaded = false
//        
//    var body: some View {
//        
//        ZStack{
//            
//            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showAlert = false
//                }
//            
//            if(isLoaded)
//            {
//                VStack{
//                    VStack {
//                        Text("累計簽到任務").font(.custom("NotoSansTC-Medium", size: 24))
//                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
//                            .fixedSize(horizontal: false, vertical: true)
//                        
//                        Divider().padding(.horizontal)
//                        
//                        VStack{
//                            Text("已經連續登入 \(loginday) 天\n請持續努力喔!!")
//                                .font(.custom("NotoSansTC-Medium", size: 16))
//                                .foregroundColor(Color.init(hex: "#76839c", alpha: 1.0))
////                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
//                                .fixedSize(horizontal: false, vertical: true)
//                            
//                            Spacer()
//                        }
//                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                        .padding()
//                        .background(Color.init(hex: "#ebeefa", alpha: 1.0))
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.init(hex: "#f3f3f3", alpha: 1.0) , lineWidth: 2)
//                        ).padding(.horizontal)
//                        .padding(.top)
//                        
//                        Button(action: {
//                            showAlert = false
//                        }, label: {
//                            Text("確定")
//                                .font(.custom("NotoSansTC-Medium", size: 16))
//                                .foregroundColor(AlertSureButtonColor)
//                                .padding(10)
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                                .background(AlertSureButtonBackgroundColor)
//                                .cornerRadius(10)
//                        })
//                        .padding()                        
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.4)
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 12)
//                }
//            }
//        }.onAppear{
//            print("開啟 ContinuousLoginAlert 頁面")
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
//}

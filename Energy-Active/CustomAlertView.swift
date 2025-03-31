//
//  CustomAlertView.swift
//  Energy-Active
//
//  Created by IIIai on 2024/5/17.
//

import SwiftUI

// MARK: - 自訂提示視窗

extension View {
    
    func environmentCustomAlertView(isPresented: Binding <Bool>, message: Binding <String>) -> some View {
        self.modifier(environmentCustomAlertViewModifier(isPresented: isPresented, message: message)
        )
    }
}

struct environmentCustomAlertViewModifier : ViewModifier {

    @EnvironmentObject var createReviseScheduleManager : CreateReviseScheduleManager
    @EnvironmentObject var electricityCustomAlertManager : CustomAlertManager
    @EnvironmentObject var electricityScheduleManager : ElectricityScheduleManager
    
    @Binding var isPresented: Bool
    @Binding var message: String
    
    func body(content: Content) -> some View {
        
        ZStack { content
            if isPresented {
                withAnimation {
                    showCustomAlertView()
                }
            }
        }
    }
}

extension environmentCustomAlertViewModifier {
    
    func showCustomAlertView() -> some View {
        ZStack {
            
            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    electricityCustomAlertManager.isPresented = false
                    createReviseScheduleManager.showAlert = false
                    electricityScheduleManager.isHistoryPage = false
                }
            
            VStack {
                Text(message)
                    .font(.custom("NotoSansTC-Bold", size: 24.0))
                    .foregroundColor(DarkGrayCustomizeColor)
                    .padding(.top, 37)
                
                Button(action: {
                    electricityCustomAlertManager.isPresented = false
                    createReviseScheduleManager.showAlert = false   
                    electricityScheduleManager.isHistoryPage = false
                
                }) {
                    Text("確定")
                        .font(.custom("NotoSansTC-Bold", size: 20.0))
                        .foregroundColor(Color(white: 1.0))
                        .frame(width: 144.0, height: 50.0)
                        .background(GreenCustomizeColor)
                        .cornerRadius(30.0)
                        .padding(.top, 37)
                }
            }
            
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(7/4, contentMode: .fit)            
            .background(Color(white: 1.0))
            .cornerRadius(10.0)
            .padding(.horizontal, 12)
        }
        
    }
}

class CustomAlertManager : ObservableObject {
    
    @Published var isPresented = false
    @Published var message : String = ""
}

// MARK: - 自訂提示視窗 舊版
//struct CustomAlertView: View {
//    @Binding var isPresented: Bool
//    @Binding var selfView: Bool
//    @Binding var showView: Bool
//    let message: String
//
//    var body: some View {
//        ZStack {
//            VStack {
//                Text(message)
//                    .font(.custom("NotoSansTC-Bold", size: 24.0))
//                    .foregroundColor(DarkGrayCustomizeColor)
//                    .padding(.top, 37)
//
//                Button(action: {
//                    isPresented = false
//                    selfView = false
//                    showView = true
//                }) {
//                    Text("確定")
//                        .font(.custom("NotoSansTC-Bold", size: 20.0))
//                        .foregroundColor(Color(white: 1.0))
//                        .frame(width: 144.0, height: 50.0)
//                        .background(GreenCustomizeColor)
//                        .cornerRadius(30.0)
//                        .padding(.top, 37)
//                }
//            }
//
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//            .aspectRatio(7/4, contentMode: .fit)
//
//            .background(Color(white: 1.0))
//            .cornerRadius(10.0)
//        }
//    }
//}


// MARK: - 自訂刪除提示視窗

extension View {
    
    func environmentCustomDeleteAlertView(isPresented: Binding <Bool>) -> some View {
        self.modifier(environmentCustomDeleteAlertViewModifier(isPresented: isPresented)
        )
    }
}

struct environmentCustomDeleteAlertViewModifier : ViewModifier {
    
    @EnvironmentObject var createReviseScheduleManager : CreateReviseScheduleManager
    @EnvironmentObject var electricityCustomAlertManager : CustomAlertManager
    @EnvironmentObject var electricityCustomDeleteAlertManager : CustomDeleteAlertManager
    @Binding var isPresented: Bool
    @State var message: String = "是否刪除？"
    
//    var delegate : SchedulePageView
    
    func body(content: Content) -> some View {
        
        ZStack { content
            if isPresented {
                withAnimation {
                    showCustomDeleteAlertView()
                }
            }
        }
    }
}

extension environmentCustomDeleteAlertViewModifier {
    
    func showCustomDeleteAlertView() -> some View {
        ZStack {
            
            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
//            Color(.clear).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    electricityCustomDeleteAlertManager.isPresented = false
                }
            
            VStack {
                Text(message)
                    .font(.custom("NotoSansTC-Bold", size: 24.0))
                    .foregroundColor(DarkGrayCustomizeColor)
                    .padding(.top, 37)
                
                
                HStack{
                    Button(action: {
                        electricityCustomDeleteAlertManager.isPresented = false
                    }) {
                        Text("取消")
                            .font(.custom("NotoSansTC-Bold", size: 20.0))
                            .foregroundColor(DarkGrayCustomizeColor)
                            .frame(width: 144.0, height: 50.0)
                            .background(GreyCustomizeColor)
                            .cornerRadius(30.0)
                    }
                    
                    Spacer()
                                     
                    Button(action: {
                        electricityCustomDeleteAlertManager.isPresented = false                  
                        electricityCustomDeleteAlertManager.isChangeDeleteBool.toggle()
                    }) {
                        Text("確定")
                            .font(.custom("NotoSansTC-Bold", size: 20.0))
                            .foregroundColor(Color(white: 1.0))
                            .frame(width: 144.0, height: 50.0)
                            .background(GreenCustomizeColor)
                            .cornerRadius(30.0)
                           
                    }
                } .padding(.top, 37).padding(.horizontal, 25)                
            }
            
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(7/4, contentMode: .fit)
            
            .background(Color(white: 1.0))
            .cornerRadius(10.0)
            .padding(.horizontal, 12)
        }
    }
}

class CustomDeleteAlertManager : ObservableObject {
    
    @Published var isPresented = false
    @Published var index : Int = 0
    @Published var isChangeDeleteBool = false
}

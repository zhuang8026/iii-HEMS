//
//  ApplianceUIView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/11.
//

import Foundation
import SwiftUI

struct ApplianceUIView: View {
    
    @Binding var showAlert: Bool
    @Binding var currentData: ApplianceDataStruct
    var applianceData : ApplianceDataStruct
    var titleName: String
    var imageName:String
    var value : Int
    var state :Int
    
    init(showAlert: Binding<Bool>, currentData: Binding<ApplianceDataStruct>,applianceData: ApplianceDataStruct) {
        self.applianceData = applianceData
        _showAlert = showAlert
        _currentData = currentData
        
        titleName = applianceData.cnName ?? "none"
        imageName = GetApplianceImageName(applianceData.name ?? "none")
        value = applianceData.value ?? 0
        
        if(value == 0)
        {
            state = 1
        }
        else{
            state = 0
        }
        // MARK: 確定該項目是否有warning ＊該項目依據文件判斷也能使用warning判斷        
        if(applianceData.warning is Int){
            if(applianceData.warning as! Int == 1)
            {
                state = 2
            }
        }
    }
    
    var body: some View {
        ZStack{
            if state == 1 {
                Image(String(imageName + "_gray")).resizable()
                
                //顯示設備名稱灰階
                VStack(alignment: .trailing){
                    HStack{
                        Spacer()
                        Text(titleName).font(.custom("NotoSansTC-Medium", size: 24.0))
                            .foregroundColor(Color(red: 172.0 / 255.0, green: 174.0 / 255.0, blue: 199.0 / 255.0))
                    }
                    Spacer()
                }.padding(.trailing, 15).padding(.top, 15)
            }
            else{
                Image(String(imageName)).resizable()

                //顯示設備名稱
                VStack(alignment: .trailing){
                    HStack{
                        Spacer()
                        Text(titleName).font(.custom("NotoSansTC-Medium", size: 24.0))
                            .foregroundColor(NavyBlueCustomizeColor)
                    }
                    Spacer()
                }.padding(.trailing, 15).padding(.top, 15)
            }
            
            // 顯示警告鈴鐺與度數
            VStack(alignment: .leading){
                Group{
                    //警告時=2 測試時可先設定為0
                    if(state == 2){
                        ZStack{
                            Circle()
                                .foregroundColor(Color(red: 1.0, green: 96.0 / 255.0, blue: 96.0 / 255.0, opacity: 0.5))
                                .frame(width: 40.0, height: 40.0)
                            Circle()
                                .foregroundColor(Color(red: 1.0, green: 96.0 / 255.0, blue: 96.0 / 255.0))
                                .frame(width: 30.0, height: 30.0)
                            Button {
                                print("按下警告標誌")
                                self.currentData = applianceData
                                self.showAlert = true
                            } label: {
                                Image("bell").resizable().scaledToFit()
                                    .frame(width: 20.0, height: 20.0)
                            }
                        }
                    }
                    else{
                        Text("").frame(width: 24.0, height: 24.0)
                    }
                }.frame(width: 40.0, height: 40.0)
                    .padding(.leading, 15).padding(.top, 15)

                Spacer()
                
                Group{
                    if state == 1{
                        Text("")
                    }
                    else{
                        Text(String(value)).font(.custom("NotoSansTC-Medium", size: 24)) +
                        Text(" 度").font(.custom("NotoSansTC-Medium", size: 24))
                    }
                }
                .padding(.leading, 15).padding(.bottom, 11)
                .foregroundColor(NavyBlueCustomizeColor)
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        }
        .cornerRadius(10)
        .aspectRatio(351/171, contentMode: .fit)
    }
}

//struct DefaultUIMode: View {
//
////    @State private var showAlert = false
//    @Binding var showAlert: Bool
//    @Binding var currentData: ApplianceDataStruct
//    var titleName: String
//    var imageName:String
//    var powerLevel : Int
//    var state :Int
//
//    var body: some View {
//
//        ZStack{
//            HStack{
//                Image(state == 1 ? String(imageName + "-disconnected") : imageName).resizable()
//                    .scaledToFit().frame(width: 50.0, height: 50.0)
//
//                VStack{
//                    HStack{
//                        Spacer()
//                        Text(titleName).padding(.vertical).font(.custom("NotoSansTC-Medium", size: 16))
//
//                        if(state == 2){
//                            Button {
//                                print("按下警告標誌(DefaultUIMode)")
//                                self.currentData = otherApplianceData[0]
//                                self.showAlert = true
//                            } label: {
//                                Image(systemName: "exclamationmark.circle.fill").resizable().scaledToFit()
//                                    .foregroundColor(Color.red)
//                                    .frame(width: 20.0, height: 20.0)
//                            }
//                        }
//                        else{
//                            Text("")
//                        }
//                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//
//                    if state == 1{
//                        Text("").frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .trailing)
//                    }
//                    else{
//                        Group{
//                            Text(String(powerLevel)).font(.custom("NotoSansTC-Medium", size: 24)) +
//                            Text(" 度").font(.custom("NotoSansTC-Medium", size: 16))
//
//                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .trailing)
//                    }
//
//                }.padding(.trailing,3)
//
//            }
////            .background(state == 1 ? EmptyView() : Image(String(imageName + "-background")).resizable().scaledToFill())
//            .background(state == 1 ? Color.init(hex: "#eff1f9", alpha: 1.0) : Color.init(hex: "#69c8be", alpha: 1.0))
////            .background(
////                state == 1 ?
////                Color.init(hex: "#eff1f9", alpha: 1.0) : Color.init(hex: "#69c8be", alpha: 1.0)
////
////                in: Image(String(imageName + "-background"))
//////                                .resizable()
//////                                .scaledToFill()
////
////
////            )
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(state == 2 ? Color.init(hex: "#ffc000", alpha: 1.0) : Color.init(hex: "#f3f3f3", alpha: 1.0), lineWidth: 2)
//            )
//            .aspectRatio(16/10, contentMode: .fit)
//        }
//    }
//}


struct ApplianceDataStruct {
    var value:Int?
    var name:String?
    var warning:Any?
    var attention:Any?
    var advice:Any?
    var advice2:Any?
    var altered:Int?
    var cnName:String?
}

struct BeyesterdayDataStruct {
    var user_id:String?
    var report_time:String?
    var yesterday:Int?
    var before_yesterday:Int?
}

func GetApplianceImageName(_ name:String) -> String{
    
    var retStr : String = ""
    
    switch (name){
//    case "tv":
//        retStr = "icon-tv"
//    case "fridge":
//        retStr = "icon-fridge"
//    case "ac":
//        retStr = "icon-ac"
//    case "water_boiler":
//        retStr = "icon-water-boiler"
//    case "washing_machine":
//        retStr = "icon-washing-machine"
//    case "other":
//        retStr = "icon-other"
//    case "computer":
//        retStr = "icon-computer"
//    case "electric_pot":
//        retStr = "icon-electric-pot"
//    case "electric_fan":
//        retStr = "icon-electric_fan"
//        
//        //除濕機未確認得到的字串
//    case "dehumidifier":
//        retStr = "icon-dehumidifier"
        

        //新素材名稱
    case "tv":  //電視
        retStr = "bg_1"
    case "fridge":  //冰箱
        retStr = "bg_2"
    case "ac":  //冷氣
        retStr = "bg_3"
    case "water_boiler":    //開飲機
        retStr = "bg_4"
    case "washing_machine": //洗衣機
        retStr = "bg_5"
    case "dehumidifier":    //除濕機
        retStr = "bg_6"
    case "computer":    //電腦
        retStr = "bg_7"
    case "electric_pot":    //電鍋
        retStr = "bg_8"
    case "electric_fan":    //電風扇
        retStr = "bg_9"

    case "other":   //其他
        retStr = "bg_10"

    default:
        retStr = "bg_10"
    }
    
    return retStr
}



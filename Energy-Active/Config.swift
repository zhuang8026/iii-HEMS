//
//  Config.swift
//  Energy-Active
//
//  Created by IIIai on 2023/6/1.
//

import Foundation
import SwiftUI

//正式伺服器
let PocUrl : String = "https://www.energy-active.org.tw/"

let ChatAIUrl : String = "https://appchat.energy-active.org.tw/"

//測試伺服器
//let PocUrl : String = "https://dev.energy-active.org.tw/"

//全域使用者ID
var CurrentUserID : String = ""

//device Token
var DeviceToken : String = ""

//宣告為全域陣列 提供所有介面使用
var otherApplianceData = [ApplianceDataStruct]()
var TotalApplianceData = [ApplianceDataStruct]()

let ApplianceDataCn = ["電視", "冰箱", "冷氣","開飲機" , "洗衣機", "除濕機", "電腦", "電鍋", "電風扇", "其他"]
let ApplianceData = ["tv", "fridge", "ac", "water_boiler", "washing_machine", "dehumidifier", "computer", "electric_pot", "electric_fan", "other"]

let BackgroundColor = Color.init(hex: "#ffffff", alpha: 1.0)
let AlertSureButtonColor = Color.init(hex: "#ffffff", alpha: 1.0)
let AlertSureButtonBackgroundColor = Color.init(hex: "#21a1a0", alpha: 1.0)
let AlertCancelButtonColor = Color.init(hex: "#21a1a0", alpha: 1.0)
let AlertCancelButtonBackgroundColor = Color.init(hex: "#eaf6f6", alpha: 1.0)

//新顏色
let GreenCustomizeColor = Color(red: 40.0 / 255.0, green: 180.0 / 255.0, blue: 179.0 / 255.0)
let GreyCustomizeColor = Color(red: 241.0 / 255.0, green: 243.0 / 255.0, blue: 252.0 / 255.0)
let NavyBlueCustomizeColor = Color(red: 50.0 / 255.0, green: 53.0 / 255.0, blue: 98.0 / 255.0)
let DarkGrayCustomizeColor = Color(red: 61.0 / 255.0, green: 102.0 / 255.0, blue: 143.0 / 255.0)

// API MOCK
var apiMock: Bool = false // API mock default: 關閉

// version
// 說明：v主版本號.次版本號.修訂號
// 主版本號（v2.0.0）：重構整個架構、重大功能變動等
// 次版本號（v0.3.0）：新增模組、介面功能等
// 修訂號（v0.0.1）：錯誤修正
var version: String = "v2.4.1-beta" // beta測試/alpha開發中/rc候選

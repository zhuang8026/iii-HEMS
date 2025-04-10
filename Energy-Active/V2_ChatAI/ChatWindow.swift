import SwiftUI
import SocketIO

//protocol AppSocketManagerDelegate {
//    func socketEmit(command: String)
//    func socketEmit(command: String, data: [String: Any])
//    
//}

//struct ChatView: View , ChatWindowDelegate {

struct ChatView: View, ChatWindowDelegate {
    @Environment(\.dismiss) var dismiss  // 獲取 dismiss 環境變數
    @State private var networkMonitor = NetworkMonitor() // 監控網路狀態（ex: 斷線）

    @State private var GLOBAL_MESSAGES: [Message] = [
//        Message(content: "用戶輸入內容", isSentByUser: false, time: "12:30"),
    ] // 全域聊天室 內容
    
    @State private var SEARCH_INFO: [Message] = [] // 用電查詢 內容
    @State private var FAQ_INFO: [Message] = [] // FAQ 訊息
    @State private var FAQ_List: [FAQList] = [] // FAQ 客製化問題
    @State private var WARNING_INFO: [Message] = [] // 異常用電 訊息

    @State var userID: String = CurrentUserID //  用戶輸入框控制
    @State private var messageText: String = "" // 用戶輸入框控制
    @State private var inquiryID: String = "" // token唯一碼
    @FocusState private var isInputFieldFocused: Bool // 鍵盤顯示控制
    @State private var isLoading: Bool = true // [聊天過程] 判斷是否顯示加載動畫
    @State private var isSearchLoading: Bool = false // [查詢中] 判斷是否顯示加載動畫
    @State private var isTransitionsLoading: Bool = true // [聊天室轉場] 判斷是否顯示加載動畫
    @State private var isWarningAbnormal: Bool = false // [異常推播] 判斷是否顯示button
    @State private var ActiveBtnName: String = "SEARCH" // 用電查詢是否被點擊
    
    @ObservedObject var socketManager : AppSocketManager
        
    var body: some View {
        ZStack(alignment: .top) {
            // Header
            VStack {
                HStack {
                    Image("chat-bot")
                        .resizable()
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("\(self.ActiveBtnName == "SEARCH" ? "用電查詢" : (self.ActiveBtnName == "FAQ" ? "FAQ" : "異常用電")) 機器人")
                            .font(.headline)
                            .foregroundColor(Color.PrimaryColor) // 使用自訂顏色
                        Text("您的省電好幫手")
                            .font(.system(size: 14)) // 設置文字大小為 14
                            .foregroundColor(Color.PrimaryColor) // 使用自訂顏色
                    }
                    Spacer()
                    // 使用 Image("out") 來退出子頁面
                    Button(action: {
                        print("異常狀態偵測")
                        self.postAbnormalSendUserID()
                        dismiss()
                        
                    }) {
                        Image("out")
                            .resizable()
                            .frame(width: 35, height: 35)
                    }
                }
                .frame(height: 60.0)
                .padding(.horizontal, 10) // 設置左右內邊距為 10 點
                .background(Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 1.0))
                .cornerRadius(30.0)
            }
            .frame(maxWidth: .infinity) // 讓 Header 擴展到螢幕的寬度
            .padding(.top, 10) // 設置左右內邊距為 10 點
            .padding(.horizontal, 10) // 設置左右內邊距為 10 點
            .alignmentGuide(.top) { _ in 0 } // 確保向上對齊
//            .position(x: UIScreen.main.bounds.width / 2, y: 40) // 固定在頂部
            
            // body
            VStack {
                // 判斷是否跳頁面，並加載動畫
                if self.isTransitionsLoading {
                    VStack {
                        Spacer()
                        // loading animation
                        ChatLoading(bgColor: Color.clear)
                            .frame(maxWidth: .infinity, alignment: .center) // 使文字在畫面置中
                        Spacer()
                    }
                } else {
                    let messageList =  self.ActiveBtnName == "SEARCH" ? self.SEARCH_INFO :
                                        (self.ActiveBtnName == "FAQ" ? self.FAQ_INFO : self.WARNING_INFO)
                    if messageList.isEmpty {
                        // messageList 為空
                        VStack {
                            Spacer()
                            Text("無聊天記錄")
                                .font(.system(size: 14)) // 設置文字大小為 14
                                .foregroundColor(Color.PrimaryColor) // 使用自訂顏色
                            Spacer()
                        }
                    } else {
                        // Chat history
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack (alignment: .leading, spacing: 12) {
                                    ForEach(messageList.indices, id: \.self) { index in
                                            let message = messageList[index]
                                            let showDate = index == 0 || messageList[index - 1].date != message.date
                                        
                                            if showDate {
                                                Text(message.date)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .padding(.bottom, 5)
                                                    .frame(maxWidth: .infinity)
                                                    .multilineTextAlignment(.center)
                                            }
    
                                            ChatBubble( message: message.content, isSentByUser: message.isSentByUser,
                                                        time: message.time, status: message.status ).id(message.id) // 設定每個訊息的ID
                                        }
                                        .padding(.top, 5)
                                        .padding(.horizontal, 10) // 在外部容器中設置左右內邊距
                                    
                                    if self.isLoading {
                                        ChatLoading().id("chat_loading") // 為 ChatLoading 設置一個 ID
                                    }
                                    if self.isSearchLoading {
                                        ChatLoading().id("search_loading") // 為 ChatLoading 設置一個 ID
                                    }
                                    Rectangle() // Or any other shape like Circle()
                                       .frame(width: 1, height: 1)
                                       .background(Color.clear)
                                       .id("chat_bottom")
                                }
                                // [進入畫面觸發] 當視圖顯示時立即滾動到最後一個訊息
                                .onAppear {
                                    // 立即滾動到最後一個訊息
                                    if let lastMessage = messageList.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
//                                    proxy.scrollTo("chat_bottom", anchor: .bottom)
                                    // 啟動網絡監控
                                    networkMonitor.startMonitoring()
                                }
                                .onDisappear {
                                    // 停止網絡監控
                                    networkMonitor.stopMonitoring()
                                }
                                // [事件觸發] 滾動到最後一個訊息
                                .onChange(of: messageList.count) { count in
                                    withAnimation {
                                        if let lastMsg = messageList.last {
                                            proxy.scrollTo(lastMsg.id, anchor: .bottom)
                                        }
                                        proxy.scrollTo("chat_bottom", anchor: .bottom)
                                    }
                                }
                                .onChange(of: isLoading) { isLoading in
                                    // 當 isLoading 改變時，確保視圖滾動到底部
                                    print("isLoading 改變時，確保視圖滾動到底部")
                                    withAnimation {
                                        proxy.scrollTo("chat_loading", anchor: .bottom)
                                    }
                                }
                                .onChange(of: isSearchLoading) { isSearchLoading in
                                    // 當 isSearchLoading 改變時，確保視圖滾動到底部
                                    print("isSearchLoading 改變時，確保視圖滾動到底部")
                                    withAnimation {
                                        proxy.scrollTo("search_loading", anchor: .bottom)
                                    }
                                }

                            }
                            .onTapGesture {
                                isInputFieldFocused = false // 點擊聊天區域時，聚焦輸入框
                            }
                        }
                        .padding(.top, 80) // 預留空間給 Header
                        .padding(.bottom, 0) // 預留空間給 Header
                    }
                }

//                Spacer()

                // Buttons & send message
                VStack(spacing: 0) {  // pacing: 0 -> 确保间距为 0
//                    let buttonTitles = [
//                        ButtonData(name: "帳密相關", value: "members_setting", prompt:"我想詢問帳密相關問題"),
//                        ButtonData(name: "系統服務", value: "device_setting", prompt: "我想詢問系統服務相關的問題"),
//                        ButtonData(name: "設備相關", value: "monthly_report", prompt: "我想詢問智慧設備相關問題")
//                    ]
                    // FAQ 快速查詢
                    if  self.ActiveBtnName == "FAQ" {
                        HStack {
                            ForEach(self.FAQ_List, id: \.value) { buttonData in
                                Button(action: {
                                    // 根据 value 调用相应的函数
                                    handleAction(for: buttonData.value, prompt: buttonData.prompt)
                                }) {
                                    Text(buttonData.name)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 30.0)
                                        .background(Color.white)
                                        .foregroundColor(Color.PrimaryColor)
                                        .cornerRadius(20.0)
                                        .font(.system(size: 14)) // 設置文字大小為 14
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20.0) // 与背景的圆角一致
                                                .stroke(Color.PrimaryColor, lineWidth: 1) // 设置边框颜色和宽度
                                        )
//                                        .shadow(color: .gray, radius: 2, x: 0, y: 2) // 添加阴影
                                }
                            }

                        }
                        .padding(.bottom, 5)  // 設置上下邊距為5點
                        .padding(.horizontal, 10)  // 設置左右邊距為10點
                    }

                    // Buttons
                    HStack {
                        // 用電查詢 按鈕
                        Button(action: {
                            // 這裡定義按鈕被點擊後要執行的動作
                            print("用電查詢 功能啟動!!!")
                            self.isTransitionsLoading = true // [開始] 加載聊天室內容
                            self.ActiveBtnName = "SEARCH" // 切換 用電查詢
                            self.postSendUserID() // [第一步] 用電查詢 -> 進入聊天視窗取得用戶token
                            self.postAbnormalSendUserID()   //異常狀態偵測
                            
                        }) {
                            Text("用電查詢")
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 0) // 下邊距 0 點
                        }
                        .buttonStyle(DefaultButtonStyle())
                        .padding(.bottom, 0) // 下邊距 0 點
                        .frame( height: 40.0)
                        .background(self.ActiveBtnName == "SEARCH" ? AnyView(activeBtn) : AnyView(inactiveBtn))
//                        .foregroundColor(Color(white: 1.0))
                        .foregroundColor(self.ActiveBtnName == "SEARCH" ? .white : Color.PrimaryColor)
                        .cornerRadius(20.0)
                        .disabled(self.ActiveBtnName == "SEARCH")
                        .disabled(self.isLoading)

                        // FAQ 按鈕
                        Button(action: {
                            // 這裡定義按鈕被點擊後要執行的動作
                            print("FAQ 功能啟動!!!")
                            self.isTransitionsLoading = true // [開始] 加載聊天室內容
                            self.ActiveBtnName = "FAQ" // 切換 FAQ
                            self.postFAQSendUserID() // [第一步] 用電查詢 -> 進入聊天視窗取得用戶token
                            self.getFAQList() // 取得FAQ問題項目
                            self.postAbnormalSendUserID()   //異常狀態偵測
                            
                        }) {
                            Text("FAQ")
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 0) // 下邊距 0 點
                        }
                        .buttonStyle(DefaultButtonStyle())
                        .padding(.bottom, 0) // 下邊距 0 點
                        .frame( height: 40.0)
                        .background(self.ActiveBtnName == "FAQ" ? AnyView(activeBtn) : AnyView(inactiveBtn))
                        .foregroundColor(self.ActiveBtnName == "FAQ" ? .white : Color.PrimaryColor)
                        .cornerRadius(20.0)
                        .disabled(self.ActiveBtnName == "FAQ")
                        .disabled(self.isLoading)
                        
                        // 異常推播 按鈕
                        if  self.isWarningAbnormal {
                            Button(action: {
                                // 這裡定義按鈕被點擊後要執行的動作
                                print("異常推播 功能啟動!!!")
                                self.isTransitionsLoading = true // [開始] 加載聊天室內容
                                self.ActiveBtnName = "WARNING" // 切換 WARNING
                                self.postAbnormalSendUserID()  // 異常狀態偵測
                                
                            }) {
                                Text("異常推播")
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, 0) // 下邊距 0 點
                            }
                            .buttonStyle(DefaultButtonStyle())
                            .padding(.bottom, 0) // 下邊距 0 點
                            .frame( height: 40.0)
                            .background(self.ActiveBtnName == "WARNING" ? AnyView(activeBtn) : AnyView(inactiveBtn))
                            .foregroundColor(self.ActiveBtnName == "WARNING" ? .white : Color.PrimaryColor)
                            .cornerRadius(20.0)
                            .disabled(self.ActiveBtnName == "WARNING")
                            .disabled(self.isLoading)
                        }
                    }
                    .padding(.horizontal, 10) // 左右內邊距 10 點
                    .padding(.top, 10) // 下邊距 0 點
                    .padding(.bottom, 0) // 下邊距 0 點
                    .background(Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 1.0))

                    // send message
                    HStack {
                        // 輸入訊息框
                        TextEditor(text: $messageText)
                            .focused($isInputFieldFocused) // 綁定焦點狀態
                            .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)) // 內邊距
                            .background(Color.background)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(Color.PrimaryColor) // 設置文字顏色為白色
                            .cornerRadius(30.0) // 圓角
                            .frame(minHeight: 50, maxHeight: .infinity) // 設置最小和最大高度
                            // .frame(height: geometry.size.height) // 設置高度為 GeometryReader 計算的高度
                            .onTapGesture {
                                isInputFieldFocused = true // 點擊時聚焦
                            }
                            .fixedSize(horizontal: false, vertical: true) // 使 TextEditor 在垂直方向上自適應

                        // 發送訊息按鈕
                        Button(action: sendMessage) {
                            Image("send")
                                .resizable()
                                .frame(width: 35, height: 35)
                        }
                        .disabled(self.isLoading)
                    }
                    .padding(10)
                    .background(Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 1.0))

                }
                .disabled(self.isLoading || self.isSearchLoading)
            }
        }
        .background(Color(red: 222/255, green: 235/255, blue: 234/255))
//        .onAppear(perform: setupSocket)
        .onAppear
        {
            socketManager.chatWindowDelegate = self
            
            // MARK: 先偵測委派狀態是否為空
            if socketManager.chatWindowDelegate == nil {
                //print("chatWindowDelegate is not set.")
            } else {
                //print("chatWindowDelegate is set.")
                                        
                self.postAbnormalSendUserID()   //異常狀態偵測
                
                if socketManager.robotExceptionIcon == true
                {
                    // 發生異常，可取正常token
                    print("[異常偵測] 偵測成功: 異常推播存在！")
//                    self.inquiryID = inquiryID
//                    self.postHistoryMessage()
//                    self.ActiveBtnName = "WARNING"
                    self.isTransitionsLoading = true // [開始] 加載聊天室內容
                    self.ActiveBtnName = "WARNING" // 切換 WARNING
                }
                else
                {
                    // 一切正常 無異常，可取正常token
                    print("[異常偵測] 偵測成功: 無異常推播存在.")
                    self.ActiveBtnName = "SEARCH"
                    self.postSendUserID() // 默認: 用電查詢 token
                }
            }
            
//            //MARK: 進入chat windows 設置徽章為 0
//            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        .onDisappear 
        {
            //MARK:  當 View 關閉時，移除委派
            socketManager.chatWindowDelegate = nil
        }
    }
    
    // has active button color
    private var activeBtn: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color.GradientStart, location: 0.0),
                Gradient.Stop(color: Color.GradientEnd, location: 1.0)
            ],
            startPoint: .trailing,
            endPoint: .leading
        )
    }
    
    // no active button color
    private var inactiveBtn: some View {
        Color.background
    }
    
    // -----------> [用電查詢] <-----------
    // MARK: [用電查詢] 取得用戶token
    private func postSendUserID() {
        let data: [String: Any] = ["user_id": userID]
//        socket.emit("/power_inquiry/status", data)
//        appSocketManagerDelegate?.socketEmit(command: "/power_inquiry/status", data: data)
        socketManager.socketEmit(command: "/power_inquiry/status", data: data)
        print("[用電查詢] 取得用戶token！")
    }

    // MARK: [用電查詢] 用戶歷史資料
    private func postHistoryMessage() {
        let data: [String: Any] = [
            "user_id": userID,
            "inquiry_id": self.inquiryID,
        ]
        print("[用戶歷史資料]用戶資料送出: \(data)")
//        socket.emit("/history_message", data)
//        appSocketManagerDelegate?.socketEmit(command: "/history_message", data: data)
        socketManager.socketEmit(command: "/history_message", data: data)
        // 打印 GLOBAL_MESSAGES 的內容
        print("[用電查詢] 取得歷史資料！")
    }
    
    // [用電查詢 & FAQ] 用戶發送訊息
    private func sendMessage() {
        // 檢查訊息是否為空
        guard !self.messageText.isEmpty else { return }
        
        // 顯示加載動畫
        self.isLoading = true
        
        // 創建一個新的訊息
        let newMessage = Message(content: self.messageText, isSentByUser: true, time: getCurrentTime(), date: getCurrentDate())

        // 將新的訊息添加到陣列中
        if self.ActiveBtnName == "SEARCH" {
            self.SEARCH_INFO.append(newMessage)
        }
        if self.ActiveBtnName == "FAQ" {
            self.FAQ_INFO.append(newMessage)
        }
        if self.ActiveBtnName == "WARNING" {
            self.WARNING_INFO.append(newMessage)
        }

        let data: [String: Any] = [
            "user_id": userID,
            "report_time": getCurrentFullTime(),
            "inquiry_id": self.inquiryID,
            "message": self.messageText
        ]
        
        var emitKey:String = ""
        switch self.ActiveBtnName {
            case "SEARCH":
                // 用電查詢 URL
                emitKey = "/power_inquiry/user_message"
                print("[SEARCH] use -> '/power_inquiry/user_message'")
            case "FAQ":
                // FAQ URL
                emitKey = "/faq/user_message"
                print("[FAQ] use -> '/faq/user_message'")
            case "WARNING":
                // 用電查詢 URL
                emitKey = "/abnormal/user_message"
                print("[FAQ] use -> '/abnormal/user_message'")
            default:
                // 用電查詢 URL
                emitKey = ""
                print("WARNING, no use anything key")
        }
        
//        socket.emit(emitKey, data)
//        appSocketManagerDelegate?.socketEmit(command: emitKey, data: data)
        socketManager.socketEmit(command: emitKey, data: data)
        
        // 清空輸入框
        self.messageText = ""
        
        // 發送後解除焦點
        isInputFieldFocused = false
    }
    
    // -----------> [FAQ] <-----------
    // [FAQ] 開始取得FAQ問題項目
    private func getFAQList() {
//        socket.emit("/faq/que")
//        appSocketManagerDelegate?.socketEmit(command: "/faq/que")
        socketManager.socketEmit(command: "/faq/que")
        print("[FAQ] 開始取得FAQ問題項目")
    }
    // [FAQ] 取得用戶token
    private func postFAQSendUserID() {
        let data: [String: Any] = ["user_id": userID]
//        socket.emit("/faq/status", data)
//        appSocketManagerDelegate?.socketEmit(command: "/faq/status", data: data)
        socketManager.socketEmit(command: "/faq/status", data: data)
        print("[FAQ] 取得用戶token！")
    }
        
    // [FAQ]
    private func handleAction(for value: String, prompt: String) {
        switch value {
            case "members_setting":
                print("會員問題: \(value) -> \(prompt)")
                // 添加會員相關的處理邏輯
            case "device_setting":
                print("設備相關: \(value) -> \(prompt)")
                // 添加設備相關的處理邏輯
            case "monthly_report":
                print("月報相關: \(value) -> \(prompt)")
                // 添加月報相關的處理邏輯
            default:
                break
        }
        self.messageText = prompt
        self.sendMessage()
    }
    
    // -----------> [異常偵測] <-----------
    // [異常偵測] 取得用戶token
    func postAbnormalSendUserID() {
        let data: [String: Any] = ["user_id": userID]
//        socket.emit("/abnormal/status", data)
//        appSocketManagerDelegate?.socketEmit(command: "/abnormal/status", data: data)
        socketManager.socketEmit(command: "/abnormal/status", data: data)
//        print(data)
    }

    // -----------> [其他] <-----------
    // 獲取當前聊天內容最後一句話是否存在 [查詢中]
    private func checkForLoading(messages: String) {
        self.isSearchLoading = messages.contains("查詢中")
        print("-- 獲取當前聊天內容最後一句話是否存在 --")
        print("對話內容: \(messages)")
        print("對話內容是否存在{查詢中}文字 ? -> \(self.isSearchLoading)")
    }
    
    //*****
    //MARK: -委派打回來的資訊
    public func disconnect(hasUserDisconnect: Bool) -> Bool
    {
        print("[用戶斷開連線] iOS client disconnected from the server")
  
        // MARK: 如果標誌變數為 true，則不再添加新的錯誤訊息
        //if hasUserDisconnect { return }
        if hasUserDisconnect { return true }
        
        // 創建一個新的訊息
        let newMessage = Message(content: "用戶斷開連線", isSentByUser: false, time: getCurrentTime(), date: getCurrentDate(), status: true)
        
        // 將新的訊息添加到陣列中
        if self.ActiveBtnName == "SEARCH" {
            self.SEARCH_INFO.append(newMessage)
        }
        if self.ActiveBtnName == "FAQ" {
            self.FAQ_INFO.append(newMessage)
        }
        if self.ActiveBtnName == "WARNING" {
            self.WARNING_INFO.append(newMessage)
        }
        
        
        self.isLoading = false // 關閉加載動畫
        self.isSearchLoading = false // 關閉加載動畫
        //hasUserDisconnect = true // 更新標誌變數
        return true // 更新標誌變數
    }
    
    public func serverError(hasServerError: Bool, data: Any) -> Bool
    {
        print("[伺服器發生錯誤] Error: \(data)")
        
        // 如果標誌變數為 true，則不再添加新的錯誤訊息
        //if hasServerError { return }
        if hasServerError { return true}
        
        // 創建一個新的訊息
        let newMessage = Message(content: "伺服器發生錯誤", isSentByUser: false, time: getCurrentTime(), date: getCurrentDate(), status: true)
        
        // 將新的訊息添加到陣列中
        if self.ActiveBtnName == "SEARCH" {
            self.SEARCH_INFO.append(newMessage)
        }
        if self.ActiveBtnName == "FAQ" {
            self.FAQ_INFO.append(newMessage)
        }
        if self.ActiveBtnName == "WARNING" {
            self.WARNING_INFO.append(newMessage)
        }
        
        self.isLoading = false // 關閉加載動畫
        self.isSearchLoading = false // 關閉加載動畫
        
        //hasServerError = true // 更新標誌變數
        return true // 更新標誌變數
    }
    
    public func statusResponse(data: [Any])
    {
        print("[接收][取得 User information] listening -> '/power_inquiry/status_response'")
        //print("[接收][取得 User information] \(data)")
                    
        guard let firstData = data.first else {
            print("沒有收到數據")
            return
        }
        
        // 處理接收到的數據
        if let jsonObject = firstData as? [String: Any] {
            print("收到的 jsonObject: \(jsonObject)")
            // 提取 "response" 字段
            if let inquiry_id = jsonObject["inquiry_id"] as? String {
                self.inquiryID = inquiry_id
                print("收到的 inquiry_id: \(inquiry_id), \(self.inquiryID)")
                self.postHistoryMessage() // [第二步] 進入聊天視窗取得用戶歷史資料
            } else {
                print("數據格式不正確，'inquiry_id' 欄位缺失或格式不正確")
            }
        } else {
            print("無法解析接收到的數據")
        }
    }
    
    public func inquiryResponse(data: [Any])
    {
        print("[接收][AI模型回話] listening -> '/broadcast/inquiry_response'")
        //print("[接收][AI模型回話] \(data)")
        // 判斷資料
        guard let firstData = data.first else {
            print("沒有收到數據")
            return
        }
        
        print("[機器人] 思考中 -> \(self.isLoading)")
        // 處理接收到的數據
        if let jsonObject = firstData as? [String: Any] {
            // 提取 "response" 字段
            if let useID = jsonObject["user_id"] as? String,
               let inquiryID = jsonObject["inquiry_id"] as? String,
               let aiMessage = jsonObject["message"] as? String,
               let reportTime = jsonObject["report_time"] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("[用電查詢] 取得 語言模型 回覆 --")
                    //print("useID: \(useID)")
                    //print("inquiryID: \(inquiryID)")
                    //print("aiMessage: \(aiMessage)")
                    if inquiryID == self.inquiryID {
                        // 創建一個新的訊息
                        let formattedTime = convertDateToTimeString(dateString: reportTime)
                        let formattedDate = convertDateToDateString(dateString: reportTime)
                        let newMessage = Message(content: aiMessage, isSentByUser: false, time: formattedTime ?? "", date: formattedDate ?? "")
                        
                        // 將新的訊息添加到陣列中
                        self.SEARCH_INFO.append(newMessage)
                        
                        // 關閉加載動畫
                        self.isLoading = false
                        // 判斷 [查詢中] 是否存在
                        self.checkForLoading(messages: aiMessage)
                    }
                }
                //                    print("收到的 ai_message: \(aiMessage)")
                
            } else {
                print("數據格式不正確，'ai_message' 欄位缺失或格式不正確")
            }
            
        } else {
            print("無法解析接收到的數據")
        }
    }
    
    
    func historyMessageResponse(data: [Any])
    {
        print("[接收][取得歷史資料] listening -> '/history_message_response'")
        //print("[接收][取得歷史資料] \(data)")

        self.SEARCH_INFO = [] // 用電查詢 記錄
        self.FAQ_INFO = [] // FAQ 記錄
        self.WARNING_INFO = [] // 聊天 記錄
        
        // 將 data 轉換為陣列
        if let dataArray = data as? [[String: Any]] {
            // 處理每個字典
            for dictionary in dataArray {
                if let status = dictionary["status"] as? String {
                    if status == "ok" {
                        print("[取得歷史資料] status: success")
                    } else {
                        print("[取得歷史資料] status: failed")
                    }
                }
                // 提取 GLOBAL_MESSAGES 陣列
                if let messagesList = dictionary["messages"] as? [[String: Any]] {
                    // 處理每個消息對象
                    for messageObj in messagesList {
                        if let message = messageObj["message"] as? String,
                           let reportTime = messageObj["report_time"] as? String,
                           let type = messageObj["type"] as? String {
                            //                                print("[消息]: \(message)")
                            //                                print("[報告時間]: \(reportTime)")
                            //                                print("[類型]: \(type)")
                            
                            // 使用 convertDateToTimeString 方法來格式化 reportTime
                            let formattedTime = convertDateToTimeString(dateString: reportTime) // HH:MM
                            let formattedDate = convertDateToDateString(dateString: reportTime) // yyyy-MM-dd
                            let newMessage = Message(content: message, isSentByUser: !(type == "AI"), time: formattedTime ?? "", date: formattedDate ?? "")
                            
                            // 判斷當前為那種類型機器人
                            switch self.ActiveBtnName {
                            case "SEARCH":
                                print("[SEARCH] >>用電查詢<< 歷史訊息 ")
                                self.SEARCH_INFO.append(newMessage)
                            case "FAQ":
                                print("[FAQ] >>FAQ<< 歷史訊息 ")
                                self.FAQ_INFO.append(newMessage)
                            case "WARNING":
                                print("[WARNING] >>異常用電<< 歷史訊息")
                                self.WARNING_INFO.append(newMessage)
                            default:
                                //print("WARNING, no use anything key: \(self.ActiveBtnName)")
                                print("WARNING, no use anything key")
                            }
                            
                            // 將新的訊息列表中的每個訊息添加到 GLOBAL_MESSAGES 中
                            //                                self.GLOBAL_MESSAGES.append(newMessage)
                        } else {
                            print("消息對象格式不正確")
                        }
                        //                            self.isLoading = false // 關閉加載動畫
                    }
                } else {
                    print("找不到 GLOBAL_MESSAGES 鍵或其格式不正確")
                }
                self.isTransitionsLoading = false // [開始] 加載聊天室內容
                self.isLoading = false  //取消讀取狀態
            }
        } else {
            print("資料格式不正確")
        }
    }
    
    public func faqQueResponse(data: [Any])
    {
        print("[FAQ][取得 FAQ list] listening -> '/faq_que_response'")
        //print("[FAQ][取得 FAQ list] \(data)")
        self.FAQ_List = []
        //            guard let firstData = data.first else {
        //                print("[FAQ] 沒有收到數據")
        //                return
        //            }
        
        // 將 data 轉換為陣列
        if let dataArray = data as? [[String: Any]] {
            // 處理每個字典
            for dictionary in dataArray {
                if let status = dictionary["status"] as? String,
                   let faqArray = dictionary["data"] as? [[String: Any]] {
                    if status == "ok" {
                        for faq in faqArray {
                            if let message = faq["message"] as? String,
                               let que_name = faq["que_name"] as? String,
                               let serial_number = faq["serial_number"] as? String {
                                let newList = FAQList(prompt: "\(message)", name: "\(que_name)", value: serial_number)
                                self.FAQ_List.append(newList)
                            }
                        }
                        print("[FAQ list] success：\(self.FAQ_List)")
                    } else {
                        print("[FAQ list] failed")
                    }
                }
            }
        } else {
            print("資料格式不正確")
        }
    }
    
    public func faqStatusResponse(data: [Any])
    {
        print("[FAQ][取得 User information] listening -> '/faq/status_response'")
        //print("[FAQ][取得 User information] \(data)")

        guard let firstData = data.first else {
            print("[FAQ] 沒有收到數據")
            return
        }
        
        // 處理接收到的數據
        if let jsonObject = firstData as? [String: Any] {
            print("[FAQ] 收到的 jsonObject: \(jsonObject)")
            // 提取 "response" 字段
            if let inquiry_id = jsonObject["inquiry_id"] as? String {
                self.inquiryID = inquiry_id
                print("[FAQ] 收到的 inquiry_id: \(inquiry_id)")
                self.postHistoryMessage() // [第二步] 進入聊天視窗取得用戶歷史資料
            } else {
                print("[FAQ] 數據格式不正確，'inquiry_id' 欄位缺失或格式不正確")
            }
        } else {
            print("[FAQ] 無法解析接收到的數據")
        }
    }
    
    public func inquiryDocsResponse(data: [Any])
    {
        print("FAQ][AI模型回話] listening -> '/broadcast/inquiry_response'")
        //            print("[FAQ][AI模型回話] \(data)")
        guard let firstData = data.first else {
            print("沒有收到數據")
            return
        }
        
        // 處理接收到的數據
        if let jsonObject = firstData as? [String: Any] {
            // 提取 "response" 字段
            if let useID = jsonObject["user_id"] as? String,
               let inquiryID = jsonObject["inquiry_id"] as? String,
               let aiMessage = jsonObject["message"] as? String,
               let reportTime = jsonObject["report_time"] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("-- [FAQ] 取得 語言模型 回覆 --")
                    print("[FAQ] useID: \(useID)")
                    print("[FAQ] inquiryID-msg: \(inquiryID)")
                    print("[FAQ] inquiryID-current: \(self.inquiryID)")
                    print("[FAQ] aiMessage: \(aiMessage)")
                    if inquiryID == self.inquiryID {
                        // 創建一個新的訊息
                        let formattedTime = convertDateToTimeString(dateString: reportTime)
                        let formattedDate = convertDateToDateString(dateString: reportTime)
                        let newMessage = Message(content: aiMessage, isSentByUser: false, time: formattedTime ?? "", date: formattedDate ?? "")
                        
                        // 將新的訊息添加到陣列中
                        self.FAQ_INFO.append(newMessage)
                        
                        // 關閉加載動畫
                        self.isLoading = false
                        
                        // 判斷 [查詢中] 是否存在
                        self.checkForLoading(messages: aiMessage)
                    }
                }
                //                    print("[FAQ] 收到的 ai_message: \(aiMessage)")
                
                
            } else {
                print("[FAQ] 數據格式不正確，'ai_message' 欄位缺失或格式不正確")
            }
        } else {
            print("[FAQ] 無法解析接收到的數據")
        }
    }
    
    public func abnormalStatusResponse(data: [Any])
    {
        //print("listening -> 'abnormal/status_response'：\(data)")
        print("[異常偵測] 異常狀態回應：abnormalStatusResponse => abnormal/status_response")
        guard let firstData = data.first as? [String: Any] else {
            print("[異常偵測] 沒有收到數據")
            return
        }
        if let status = firstData["status"] as? String {
            if status == "ok" {
//                if let inquiryID = firstData["inquiry_id"] as? String, !inquiryID.isEmpty {
//                    print("[異常偵測] 取得用戶token！")
//                    print("[異常偵測] 成功: inquiry_id 存在且有值: \(inquiryID)")
//                    self.inquiryID = inquiryID
//                    self.postHistoryMessage() // [第二步] 進入聊天視窗取得用戶歷史資料
//                    self.ActiveBtnName = "WARNING"
//                    self.isWarningAbnormal = true // 顯示 異常推播 按鈕                    
//                    socketManager.robotExceptionIcon = true //  開啟異常推播Icon
//                    return
//                } else {
//                    // 一切正常 無異常，可取正常token
//                    print("[異常偵測] 成功: 但是 inquiryID 不存在或為空（無異常）")
//                    self.ActiveBtnName = "SEARCH"
//                    self.isWarningAbnormal = false // 隱藏 異常推播 按鈕
//                    socketManager.robotExceptionIcon = false //  關閉異常推播Icon
//                    self.postSendUserID() // 默認: 用電查詢 token
//                    
//                }
                
                if let inquiryID = firstData["inquiry_id"] as? String, !inquiryID.isEmpty {
                    //print("[異常偵測] 取得用戶token！")
                    print("[異常偵測] 成功: inquiry_id 存在且有值: \(inquiryID)")
                    self.inquiryID = inquiryID
                    if (self.ActiveBtnName == "WARNING")
                    {
                        //MARK: 若現在為異常推播視窗才讀取文字
                        self.postHistoryMessage()
                    }
                    //self.ActiveBtnName = "WARNING"
                    
                    self.isWarningAbnormal = true // 顯示 異常推播 按鈕
                    socketManager.robotExceptionIcon = true //  開啟異常推播Icon
                    return
                } else {
                    // 一切正常 無異常，可取正常token
                    print("[異常偵測] 成功: 但是 inquiryID 不存在或為空（無異常）")
                    //self.ActiveBtnName = "SEARCH"
                    //self.postSendUserID() // 默認: 用電查詢 token
                    
                    self.isWarningAbnormal = false // 隱藏 異常推播 按鈕
                    socketManager.robotExceptionIcon = false //  關閉異常推播Icon
                    UIApplication.shared.applicationIconBadgeNumber = 0 //  無異常狀態時,勳章狀態數字應為0
                }
                
            } else {
                // 異常偵測 API Fail，可取正常token
                if let error = firstData["err"] as? String {
                    print("[異常偵測] 失敗: \(error)")
                } else {
                    print("[異常偵測] 失敗: 未知錯誤")
                }
                //self.postSendUserID() // 默認: 用電查詢 token
            }
            
        } else {
            print("[異常偵測] 無法解析狀態")
        }
    }
    
    public func broadcastResponse(data: [Any])
    {
        //print("listening -> '/broadcast_response'：\(data)")
        
        print("[介面端] 接收到 /broadcast_response")
        
        guard let firstData = data.first else {
            print("沒有收到數據")
            return
        }
        
        // 處理接收到的數據
        if let jsonObject = firstData as? [String: Any] {
            // 提取 "response" 字段
            if let useID = jsonObject["user_id"] as? String,
               let inquiryID = jsonObject["inquiry_id"] as? String,
               let aiMessage = jsonObject["message"] as? String,
               let reportTime = jsonObject["report_time"] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("[異常偵測] 取得 語言模型 回覆('/broadcast_response') --")
                    //print("aiMessage: \(useID)")
                    //print("aiMessage-tokenID: \(inquiryID), \(self.inquiryID)")
                    //print("aiMessage: \(aiMessage)")
                    
                    if self.userID == useID {
                        self.inquiryID = inquiryID
                        self.postHistoryMessage() // [第二步] 進入聊天視窗取得用戶歷史資料
                        self.ActiveBtnName = "WARNING"
                        self.isWarningAbnormal = true // 顯示 異常推播 按鈕
                    }
                    
                    // 判斷推播訊息是否為 當前用戶
                    if inquiryID == self.inquiryID {
                        // 創建一個新的訊息
                        let formattedTime = convertDateToTimeString(dateString: reportTime)
                        let formattedDate = convertDateToDateString(dateString: reportTime)
                        let newMessage = Message(content: aiMessage, isSentByUser: false, time: formattedTime ?? "", date: formattedDate ?? "")
                        
                        // 將新的訊息添加到陣列中
                        self.WARNING_INFO.append(newMessage)
                        
                        // 關閉加載動畫
                        self.isLoading = false
                        
                        // 判斷 [查詢中] 是否存在
                        self.checkForLoading(messages: aiMessage)
                    }
                }
                //print("[FAQ] 收到的 ai_message: \(aiMessage)")
                
                
            } else {
                print("[FAQ] 數據格式不正確，'ai_message' 欄位缺失或格式不正確")
            }
        } else {
            print("[FAQ] 無法解析接收到的數據")
        }
    }
    
    public func userMessageResponse(data: [Any])
    {
        //print("listening -> '/abnormal/user_message_response'： \(data)")
        //print("[介面端]接收到 /abnormal/user_message_response : \(data)" )
        print("[介面端]接收到 /abnormal/user_message_response " )
        
        guard let firstData = data.first else {
            print("沒有收到數據")
            return
        }
        
        if let jsonObject = firstData as? [String: Any] {
            if let status = jsonObject["status"] as? String {
                if status == "end" {
                    
                    // 創建一個新的訊息
                    let newMessage = Message(content: "此問題已結束", isSentByUser: false, time: getCurrentTime(), date: getCurrentDate(), status: false)
                    // 將新的訊息添加到陣列中
                    self.WARNING_INFO.append(newMessage)
                    self.isLoading = false
                    
                    print("關閉異常推播Icon 結束點2")
                    //  關閉異常推播Icon
                    socketManager.robotExceptionIcon = false
                    
                    //MARK: 結束異常時 設置徽章為 0
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    
                    // 關閉加載動畫
                    self.isLoading = false
                }
                else if status == "ok" {
                    
                    let msg = jsonObject["msg"] as? String
                    if msg == "no abnormal"
                    {
                        print("關閉異常推播Icon 結束點1")
                        //  關閉異常推播Icon
                        socketManager.robotExceptionIcon = false
                        
                        //MARK: 結束異常時 設置徽章為 0
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                }
            }
            
        }
    }

    // 獲取當前時間的函數 yyyy-MM-dd HH:mm:ss
    private func getCurrentFullTime(timeZone: TimeZone? = TimeZone(identifier: "Asia/Taipei")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone // 設定用戶自定義的時區
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 設定日期格式
        return dateFormatter.string(from: Date())
    }

    // 獲取當前時間的函數 yyyy-MM-dd
    private func getCurrentDate(timeZone: TimeZone? = TimeZone(identifier: "Asia/Taipei")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone // 設定用戶自定義的時區
        dateFormatter.dateFormat = "yyyy-MM-dd" // 設定日期格式
        return dateFormatter.string(from: Date())
    }

    // 獲取當前時間的函數 HH:mm
    private func getCurrentTime(timeZone: TimeZone? = TimeZone(identifier: "Asia/Taipei")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone // 設定用戶自定義的時區
        dateFormatter.dateFormat = "HH:mm" // 設定日期格式
        return dateFormatter.string(from: Date())
    }

    // 將日期時間字串轉換為指定格式的時間字串
    // ex: 2024-08-01 17:25:05  轉成 17:25
    private func convertDateToTimeString(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        
        // 設定原始日期時間字串的格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // 解析日期時間字串為 Date 對象
        if let date = dateFormatter.date(from: dateString) {
            // 設定轉換後的時間格式
            dateFormatter.dateFormat = "HH:mm"
            // 返回格式化後的時間字串
            return dateFormatter.string(from: date)
        }
        
        // 如果無法解析，返回 nil
        return nil
    }
    
    // 將日期時間字串轉換為指定格式的時間字串
    // ex: 2024-08-01 17:25:05  轉成 2024-08-01
    private func convertDateToDateString(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        
        // 設定原始日期時間字串的格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // 解析日期時間字串為 Date 對象
        if let date = dateFormatter.date(from: dateString) {
            // 設定轉換後的時間格式
            dateFormatter.dateFormat = "yyyy-MM-dd"
            // 返回格式化後的時間字串
            return dateFormatter.string(from: date)
        }
        
        // 如果無法解析，返回 nil
        return nil
    }
}

//struct ChatWindow: View {
////    @State private var isChatViewPresented = false // 子頁面控制器（默認：關閉）
//    
//    var body: some View {
//        VStack {
//            // 點擊這個圖標來開啟 ChatView
////            Button(action: {
////                isChatViewPresented = true
////            }) {
////                Image(systemName: "message.circle.fill")
////                    .resizable()
////                    .frame(width: 50, height: 50)
////            }
////            .sheet(isPresented: $isChatViewPresented) {
////                ChatView()
////            }
//        }
//    }
//}

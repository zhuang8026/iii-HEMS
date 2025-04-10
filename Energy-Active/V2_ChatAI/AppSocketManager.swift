//
//  SocketManager.swift
//  Energy-Active
//
//  Created by IIIai on 2024/10/15.
//

import SocketIO

protocol ChatWindowDelegate {
//    func disconnect(activeBtnName: String)
    func postAbnormalSendUserID()
    func disconnect(hasUserDisconnect: Bool) -> Bool
    func serverError(hasServerError: Bool, data: Any) -> Bool
    func statusResponse(data: [Any])
    func inquiryResponse(data: [Any])
    func historyMessageResponse(data: [Any])
    func faqQueResponse(data: [Any])
    func faqStatusResponse(data: [Any])
    func inquiryDocsResponse(data: [Any])
    func abnormalStatusResponse(data: [Any])
    func broadcastResponse(data: [Any])
    func userMessageResponse(data: [Any])
}

// -----------> [Soctet] <-----------
class AppSocketManager: ObservableObject {
    @Published var robotExceptionIcon: Bool = false //更新異常資訊圖示
    @Published var socketReady: Bool = true //socket 建立狀態
    @Published var isConnected = false
//    private let manager = SocketManager(socketURL: URL(string: "http://54.65.71.9:5000")!, config: [.log(true), .compress])
//    private let manager = SocketManager(socketURL: URL(string: ChatAIUrl)!, config: [.log(true), .compress])
    private let manager = SocketManager(socketURL: URL(string: ChatAIUrl)!, config: [.log(true), .compress, .forceWebsockets(true)])

    private var socket: SocketIOClient { return manager.defaultSocket }
        
    public var chatWindowDelegate: ChatWindowDelegate?
            
    public func setupSocket() {

        // 定義一個標誌變數
        var hasServerError = false
        var hasUserDisconnect = false
        
        // MARK: socket連線狀態
        socket.on(clientEvent: .connect) { data, ack in
            print("iOS client connected to the server; data: \(data)")
            
            // 異常用電token，有異常時，token 會被“異常用電token”取代
            self.chatWindowDelegate?.postAbnormalSendUserID()

            hasServerError = false
            hasUserDisconnect = false
        }
        
        // MARK: 用戶斷開連線
        socket.on(clientEvent: .disconnect) { data, ack in
            print("[用戶斷開連線] iOS client disconnected from the server")
            hasServerError = ((self.chatWindowDelegate?.disconnect(hasUserDisconnect: hasUserDisconnect)) != nil)
        }
        
        // MARK: 伺服器發生錯誤
        socket.on(clientEvent: .error) { data, ack in
            print("[伺服器發生錯誤] Error: \(data)")
            hasUserDisconnect = ((self.chatWindowDelegate?.serverError(hasServerError: hasServerError, data: data)) != nil)
        }
        
        // MARK: 監聽 server 端回傳數據
        // --------- [用電查詢] ---------
        // [用電查詢] 取得 User information（get token）
        socket.on("/power_inquiry/status_response") { data, ack in
            //print("listening -> '/power_inquiry/status_response'")
            print("[接收][取得 User information] \(data)")
            self.chatWindowDelegate?.statusResponse(data: data)
        }
        
        // MARK: [用電查詢] 取得 語言模型 回覆
        socket.on("/broadcast/inquiry_response") { data, ack in
            //print("listening -> '/broadcast/inquiry_response'")
            print("[接收][AI模型回話] \(data)")
            self.chatWindowDelegate?.inquiryResponse(data: data)
        }
        
        // MARK: [FAQ]    -> 取得 “歷史“ 資料
        // MARK: [用電查詢] -> 取得 “歷史“ 資料
        // MARK: [異常偵測] -> 取得 “歷史“ 資料
        socket.on("/history_message_response") { data, ack in
            //print("listening -> '/history_message_response'")
            print("[接收][取得歷史資料] \(data)")
            
            self.chatWindowDelegate?.historyMessageResponse(data: data)
        }
        
        // MARK: --------- [FAQ] ---------
        // [FAQ][FAQ list]
        socket.on("/faq_que_response") { data, ack in
            //print("listening -> '/faq_que_response'")
            print("[FAQ][取得 FAQ list] \(data)")
            self.chatWindowDelegate?.faqQueResponse(data: data)
        }
        
        // MARK: [FAQ] 取得 User information（get token）
        socket.on("/faq/status_response") { data, ack in
            //print("listening -> '/faq/status_response'")
            print("[FAQ][取得 User information] \(data)")
            self.chatWindowDelegate?.faqStatusResponse(data: data)
        }
        
        // MARK: [FAQ] 取得 語言模型 回覆
        socket.on("/broadcast/inquiry/docs_response") { data, ack in
            //print("listening -> '/broadcast/inquiry_response'")
            print("[FAQ][AI模型回話] \(data)")
            self.chatWindowDelegate?.inquiryDocsResponse(data: data)
        }
        
        // MARK: --------- [異常偵測] ---------
        // [異常偵測] 取得 狀態（是否有異常）
        socket.on("/abnormal/status_response") { data, ack in
            print("[異常偵測] 開始取得異常推播狀態 /abnormal/status_response")
            // 檢查委派對象是否實作了 abnormalStatusResponse(data:)
            if let delegate = self.chatWindowDelegate {
                print("[異常偵測] 委派 /abnormal/status_response 存在")
                delegate.abnormalStatusResponse(data: data) // 安全地調用可選方法
            } 
            else {
                print("[異常偵測] 委派 /abnormal/status_response 不存在或未實作 僅更新Icon.")
                self._abnormalStatusResponse(data: data)
            }
        }
        
        // MARK: [異常偵測] 異常即時廣播 語言模型 回覆
        socket.on("/broadcast_response") { data, ack in
            //print("listening -> '/broadcast_response'：\(data)")
            print("[異常偵測] 已偵測到 語言模型 異常推播回覆 /broadcast_response")
            // 檢查委派對象是否實作了 broadcastResponse(data:)
            if let delegate = self.chatWindowDelegate {
                print("[異常偵測] 委派 /broadcast_response 存在")
                delegate.broadcastResponse(data: data) // 安全地調用可選方法
            } else {
                print("[異常偵測] 委派 /broadcast_response 不存在或未實作 僅更新Icon.")
                self._abnormalStatusResponse(data: data)
                
                
            }
        }
        
        // MARK: [異常偵測] 檢查 語言模型 回覆
        // status == end ? '此問題已結束' : '話題繼續'
        socket.on("/abnormal/user_message_response") { data, ack in
            //print("listening -> '/abnormal/user_message_response'： \(data)")
            print("[異常偵測] 已偵測到 異常資訊 /abnormal/user_message_response")
            self.chatWindowDelegate?.userMessageResponse(data: data)
        }
        
        // MARK: 監聽 `connect` 確認連接成功
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            //print("SocketManager: Connected successfully!")
            DispatchQueue.main.async {
                print("Socket Server 連線成功")
                self?.isConnected = true
                
                // MARK: 偵測機器人圖示是否為異常
                let data: [String: Any] = ["user_id": CurrentUserID]
                self?.socket.emit("/abnormal/status", data)
            }
        }
        
        // MARK: 監聽連接失敗的情況
        socket.on(clientEvent: .error) { [weak self] data, ack in
            //print("SocketManager: Connection failed with error: \(data)")
            DispatchQueue.main.async {
                print("Socket Server 連線失敗")
                self?.isConnected = false
            }
        }
        
        // 監聽斷線的情況
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            //print("SocketManager: Connection failed with error: \(data)")
            DispatchQueue.main.async {
                print("Socket Server 連線斷線")
                self?.isConnected = false
            }
        }
                
        // socket 連接
        socket.connect()
                
        print("Socket Server 連線中")

    }
    
    // MARK: 偵測異常狀態
    func postAbnormalSendUserID()
    {
        // 異常用電token，有異常時，token 會被“異常用電token”取代
        self.chatWindowDelegate?.postAbnormalSendUserID()
    }
    
    // MARK: 傳遞command
    func socketEmit(command: String)
    {
        socket.emit(command)
    }
    
    // MARK: 傳遞command
    func socketEmit(command: String, data: [String: Any])
    {
        socket.emit(command, data)
    }    
    
    // MARK: 異常偵測, 僅用來更新圖示用
    public func _abnormalStatusResponse(data: [Any])
    {
        //print("listening -> 'abnormal/status_response'：\(data)")
        guard let firstData = data.first as? [String: Any] else {
            print("[異常偵測] 沒有收到數據")
            return
        }
        if let status = firstData["status"] as? String {
            if status == "ok" {
                //MARK: inquiryID不為空時 才確認為異常推播
                if let inquiryID = firstData["inquiry_id"] as? String, !inquiryID.isEmpty {
                    print("[異常偵測] 偵測成功: 異常推播存在！")
                    self.robotExceptionIcon = true //  開啟異常推播Icon
                    //return
                } else {
                    // 一切正常 無異常，可取正常token
                    print("[異常偵測] 偵測成功: 無異常推播存在.")
                }
            } else {
                // 異常偵測 API Fail，可取正常token
                if let error = firstData["err"] as? String {
                    print("[異常偵測] 偵測失敗: 錯誤訊息 -> \(error)")
                } else {
                    print("[異常偵測] 偵測失敗: 未知錯誤")
                }
            }
            
        } else {
            print("[異常偵測] 無法解析狀態")
        }
        
        if(self.socketReady)
        {
            self.socketReady = false
        }
    }
}

//
//  LoginView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/3/6.
//

import SwiftUI
import WebKit

struct LoginView: View {
    
    @Binding var loginflag:Bool
    @State var error: Error? = nil
    @State var isLogin: Bool = true
    @State private var canGoBack = true
    
    @StateObject private var networkManager = NetworkManager()
    
    var body: some View {
        VStack{
            if(!isLogin)
            {
                LoginWebView(url: URL(string: "\(PocUrl)login")!,
                             messageHandler: MessageHandler(loginflag: $loginflag), isLogin: isLogin)
                .onLoadStatusChanged {(loading, error) in
                    if loading {
                        print("Login View Loading ...")
                    }
                    else {
                        print("Done loading.")
                    }
                }
            }
        }
        .onAppear{
            print("進入登入頁面")
            if(UserDefaults.standard.string(forKey: "user_password") == "")
            {
                isLogin = false
            }
            else{
                GetLoginStatus()
//                Task{
//                    await networkManager.testURLRequest()
//                }
            }
        }
    }
    
    func GetLoginStatus(){
        
        let session = URLSession(configuration: .default)
        
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""

        // 設定URL
        let url = PocUrl + "api/main/trace/yesterday"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET yesterday)")
            //print(response)
            //print(data)
            // MARK: 解析json
            do {
                if(data != nil){
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    //print(json)
                    let json_data = json?["message"] as! String
                    print(json_data)
                    
                    if(json_data.contains("操作成功"))
                    {
                        isLogin = true
                        loginflag = false
                    }
                    else{
                        isLogin = false
                    }
                }
                else{
                    print("Get yesterday API is null")
                    isLogin = false
                }
                
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginflag: .constant(true))
    }
}

struct LoginWebView: UIViewRepresentable {
    let view = WKWebView()
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var messageHandler: MessageHandler
    var isLogin : Bool
//    var delegate: WebViewDelegate = WebViewDelegate()  //超連結處理
//    @Binding var canGoBack: Bool // 控制是否能返回上一頁
    
    func makeCoordinator() -> LoginWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
//        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.configuration.userContentController.add(messageHandler, name: "MessageHandler")
        // Load cookies into HTTPCookieStorage
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
        
        //若非登入狀態則刪除
        if(isLogin == false){
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
        }
        
        view.load(URLRequest(url: url))
//        view.navigationDelegate = delegate  //超連結委派處理
//
//        // 新增左滑手勢識別功能
//        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleSwipeGesture(_:)))
//        swipeGesture.direction = .right
//        view.addGestureRecognizer(swipeGesture)
        
        return view
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // you can access environment via context.environment here
        // Note that this method will be called A LOT
        //        print("updateUIView")
//        canGoBack = uiView.canGoBack // 更新能否返回上一頁的狀態
    }
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
//    func goBack() {
//        view.goBack() // 返回上一页
//    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: LoginWebView
        
        init(_ parent: LoginWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
            print("webView Fail")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated  {
                if let url = navigationAction.request.url,
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    print(url)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let userID = UserDefaults.standard.string(forKey: "user_id") ?? ""
            let userPassword = UserDefaults.standard.string(forKey: "user_password") ?? ""
            
//            let userID = "billdavid50814@gmail.com";
//            let userPassword = "Enargy17885@";

//            let userID = "Asd@iii.org.tw";
//            let userPassword = "a1234567A@";
            
//            let userID = "jenny0127h@gmail.com";
//            let userPassword = "Jenny0127h@";
            
//            let userID = "martin80712@gmail.com";
//            let userPassword = "@Ss8611577";
            
            // MARK: 自動輸入帳號密碼
            let script:String = """
                var simulate_evt = new InputEvent('input',{ inputType: 'insertText', data: ' ', dataTransfer: null, isComposing: false });
                let id_element = document.getElementsByClassName("el-input__inner")[0];
                let pw_element = document.getElementsByClassName("el-input__inner")[1];
                let login_button = document.getElementsByClassName(\"el-button btn btn-main-color el-button--default\")[0];
                id_element.value= "\(userID)";
                pw_element.value= "\(userPassword)";
                id_element.dispatchEvent(simulate_evt);
                pw_element.dispatchEvent(simulate_evt);
                """
            
            webView.evaluateJavaScript(script){ (result, error) in
                if error == nil {
                    //                    print(result ?? "script error")
                    print("Login View success")
                }else{
                    self.parent.loadStatusChanged?(false, nil)
                }
            }
                        
            //MARK: 自動登入按鈕自己按下*修改為密碼不為空才按下
            if (userPassword != "")
            {
                webView.evaluateJavaScript("login_button.click();"){ (result, error) in
                    if error == nil {
                        //                    print(result ?? "script error")
                        print("auto login success")
                    }else{
                        self.parent.loadStatusChanged?(false, nil)
                    }
                }
            }
            
            let jsRecordPayload: String = """
                    
                    XMLHttpRequest.prototype.origOpen = XMLHttpRequest.prototype.open;
                    XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
                        this.recordedMethod = method;
                        this.recordedUrl = url;
                        this.origOpen(method, url, async, user, password);
                        
                    };
                    
                    XMLHttpRequest.prototype.origSend = XMLHttpRequest.prototype.send;
                    
                    XMLHttpRequest.prototype.send = function(body) {
                        if(body){
                            //偵測到yesterday攔截
                            if(this.recordedUrl.includes("beyesterday"))
                            {
                                //攔截response訊息
                                var self = this;
                                this.onreadystatechange = function() {
                                    if (self.readyState === 4 && self.status === 200) {
                                        window.webkit.messageHandlers.MessageHandler.postMessage(self.responseText);
                                        //window.webkit.messageHandlers.MessageHandler.postMessage(this.recordedUrl);
                                        //var obj = JSON.parse(self.responseText);
                                        //window.webkit.messageHandlers.MessageHandler.postMessage(obj.message);
                                    }
                                };
                            }
                        }
                        this.origSend(body);
                    };
                    
                    """
            
            webView.evaluateJavaScript(jsRecordPayload, completionHandler: { result, error in
                if error == nil {
                    print("success")
                }else{
                    //                    print("jsRecordPayload error")
                }
            } )
        }
    }
}

class MessageHandler: NSObject, WKScriptMessageHandler {
    //    @Binding var response: String
    @Binding var loginflag: Bool
    
    init(loginflag: Binding<Bool>) {
        _loginflag = loginflag
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let responseString = message.body as? String {
            
            //print(responseString)
            
            // MARK: 讀取使用者ID
            message.webView?.evaluateJavaScript("id_element.value", completionHandler: { result, error in
                if let data = result as? String {
                    // parse datHtml here
//                    print("id_element.value : " + data)
//                    print("confirm get id_element value.")
                    //寫入user id to phone
                    CurrentUserID = data
                    UserDefaults.standard.set(data, forKey: "user_id")
                    
                    // MARK: 儲存token
                    self.GET_URLRequest_Token(data)
                }
            } )
            
            
            // MARK: 讀取使用者PASSWORD
            message.webView?.evaluateJavaScript("pw_element.value", completionHandler: { result, error in
                if let data = result as? String {
                    // parse datHtml here
//                    print("pw_element.value : " + data)
//                    print("confirm get pw_element value.")
                    //寫入user password to phone
                    UserDefaults.standard.set(data, forKey: "user_password")
                    
                    Thread.sleep(forTimeInterval: 1)
                    
                    //寫入密碼完成時準備切換介面
                    do {
                        //MARK: 讀取操作成功
                        let json = try JSONSerialization.jsonObject(with: Data(responseString.utf8), options: []) as? [String : Any]
                        let message : String = json?["message"] as! String
                        let isPass : Bool = message.contains("操作成功")
                        if isPass {                            
                            self.loginflag = false
                            print("login pass.")
                        }
                    } catch {
                        print("error decode message.")
                    }
                    
                }
            } )
            
//            do {
//                //MARK: 讀取操作成功
//                let json = try JSONSerialization.jsonObject(with: Data(responseString.utf8), options: []) as? [String : Any]
//                let message : String = json?["message"] as! String
//                let isPass : Bool = message.contains("操作成功")
//                if isPass {
//                    loginflag = false
//                    print("login pass.")
//                }
//            } catch {
//                print("error decode message.")
//            }
//            print(responseString)
        }
    }
    
    // MARK: - 取得token
    func GET_URLRequest_Token(_ user_id : String){
        let session = URLSession(configuration: .default)
        
        let url = PocUrl +  "api/nilm09/gettoken?user_id=\(user_id)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
                print("連線到伺服器 (GET Token)")
                //                print(response)
                //                print(data)
                
                // MARK: 解析json
                do {
//                    let content = String(data: data!, encoding: .utf8)
//                    print("Get token => ", content)
                    let decodeData = try JSONDecoder().decode(GettokenCodable.self, from: data!)
//                    print("decodeData token => ", decodeData.access_token)
                                        
                    UserDefaults.standard.set(decodeData.access_token!, forKey: "access_token")
                    
                    print("GET Token Pass")
                } catch {
                    print(error)
                }
        }
        task.resume()
    }
    
    struct GettokenCodable: Codable{
        let user_id:String?
        let access_token:String?
    }
}



@MainActor
class NetworkManager: ObservableObject {
    @Published var showAlert: Bool = false

    func testURLRequest() async {
        guard let url = URL(string: "https://www.google.com") else {
            print("Invalid URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }

            // 成功取得資料
            print("Data received: \(data)")
        } catch {
            print("Network error: \(error.localizedDescription)")
            await MainActor.run {
                showAlert = true
            }
        }
    }
}

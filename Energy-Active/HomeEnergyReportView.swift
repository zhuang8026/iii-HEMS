//
//  HomeEnergyReportView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/3/6.
//

import SwiftUI
import WebKit

struct HomeEnergyReportView: View {
    
    @Binding var loginflag:Bool
    @Binding var robotIconDisplay:Bool
    @Binding var forapp:Forapp
    @State var error: Error? = nil
    @State var isLogin: Bool = false
    @State private var shouldReload = false
    @State private var isAtTop: Bool = true
    
    @State private var canGoBack = true
    var body: some View {
        VStack{
            
            ZStack (alignment: .top){
                HomeEnergyReportWebView(url: URL(string: "\(PocUrl)news")!, messageHandler: HomeEnergyReportHandler(isConfirm: $loginflag, forapp: $forapp), loginflag: $loginflag, shouldReload: $shouldReload, canGoBack: $canGoBack, isAtTop: $isAtTop)
                    .onLoadStatusChanged {(loading, error) in
                        if loading {
                            print("Loading…")
                        }
                        else {
                            print("Done loading.")
                        }
                    }
                    .overlay(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .named("webView")).minY) { newValue in
                                    if newValue > 0 {
                                        isAtTop = true
                                    } else {
                                        isAtTop = false
                                    }
                                }
                        }
                            .frame(height: 0), alignment: .top
                    )
                
                Group{
                    Image("top-title").resizable().scaledToFit()
                        .frame(width: 177.0, height: 27)
                }.frame(height: 50.0).frame(minWidth: 0, maxWidth: .infinity)                    
                    .background(.white)
                    
            }
            Spacer()
            
        }.onAppear{
            print("進入家庭能源報告頁面")
            //重新讀取介面
            shouldReload = true
            // MARK: 機器人圖示為開啟
            self.robotIconDisplay = true
        }
    }
}

//struct HomeEnergyReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeEnergyReportView(loginflag: .constant(true))
//    }
//}


struct HomeEnergyReportWebView: UIViewRepresentable {   
    var view = WKWebView()
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var messageHandler: HomeEnergyReportHandler
    @Binding var loginflag: Bool
    @Binding var shouldReload: Bool
    
    var delegate: WebViewDelegate = WebViewDelegate()  //超連結處理
    @Binding var canGoBack: Bool // 控制是否能返回上一頁
    
    @Binding var isAtTop: Bool
    
    func makeCoordinator() -> HomeEnergyReportWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        view.navigationDelegate = context.coordinator
        view.configuration.userContentController.add(messageHandler, name: "HomeEnergyReportHandler")
        // Load cookies into HTTPCookieStorage
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
        view.load(URLRequest(url: url))
//        view.navigationDelegate = delegate  //超連結委派處理
        
        // 新增左滑手勢識別功能
        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleSwipeGesture(_:)))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
        
        return view
    }    
        
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if shouldReload {
//            view.reload()
            view.load(URLRequest(url: url))
            shouldReload = false
            uiView.scrollView.isScrollEnabled = !isAtTop
        }
        
        canGoBack = uiView.canGoBack // 更新能否返回上一頁的狀態
    }
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    func goBack() {
        view.goBack() // 返回上一页
    }

    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HomeEnergyReportWebView
        
        init(_ parent: HomeEnergyReportWebView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.y <= 0 {
                parent.isAtTop = true
            } else {
                parent.isAtTop = false
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
            print("webView Fail")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            //重新導向登入頁面時
            if (webView.title! == "用戶登入")
            {
                //返回登入介面
                parent.loginflag = true
            }
            
            // 在這裡處理超連結的點擊事件
            if let urlx = navigationAction.request.url {
                // 你可以檢查 url，然後決定是否打開連結
//                print("User clicked on URL: \(urlx)")
                if(webView.url != urlx)
                {
                    print("URL : \(urlx)")
                    let request = URLRequest(url: urlx)
                    webView.load(request)
                }
            }
            
            if navigationAction.navigationType == .formResubmitted {
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
            print("週月報網頁讀取完成")
                           
            //偵測weekly_msg 

            let jsRecordPayload = """
                        (function() {
                            XMLHttpRequest.prototype.origOpen = XMLHttpRequest.prototype.open;
                            XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
                                this.recordedMethod = method;
                                this.recordedUrl = url;
                                this.origOpen(method, url, async, user, password);
                            };
                        
                            XMLHttpRequest.prototype.origSend = XMLHttpRequest.prototype.send;
                        
                            XMLHttpRequest.prototype.send = function(body) {
                                // 向 Swift 發送請求 URL
                                //window.webkit.messageHandlers.HomeEnergyReportHandler.postMessage(this.recordedUrl);
                        
                                if (this.recordedUrl.includes("weekly_msg")) {
                                    var self = this;
                                    this.onreadystatechange = function() {
                                        if (self.readyState === XMLHttpRequest.DONE) {
                                            window.webkit.messageHandlers.HomeEnergyReportHandler.postMessage(self.responseText);
                                        }
                                    };
                                }
                                this.origSend(body);
                            };
                        })();
                        """
            
            webView.evaluateJavaScript(jsRecordPayload, completionHandler: { result, error in
                if error == nil {
                    print("JavaScript injected successfully")
                } else {
                    print("JavaScript injection failed: \(String(describing: error))")
                }
            })
            
            
            if(!webView.url!.absoluteString.contains("news"))
            {
                //返回登入介面
                parent.loginflag = true
            }
                         
        }

        
        @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
            if gesture.direction == .right {
                print("Back previous page")
                parent.goBack() // 返回上一頁
            }
        }
    }
    
    class WebViewDelegate: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let urlx = navigationAction.request.url {
                // 在這裡處理超連結的點擊事件
                // 你可以檢查 url，然後決定是否打開連結
//                print("User clicked on URL: \(urlx)")
                if(webView.url != urlx)
                {
                    print("URL : \(urlx)")
                    let request = URLRequest(url: urlx)
                    webView.load(request)
                }
            }
            decisionHandler(.allow)
        }
    }
}


class HomeEnergyReportHandler: NSObject, WKScriptMessageHandler {
    @Binding var isConfirm: Bool
    @Binding var forapp: Forapp

    init(isConfirm: Binding<Bool>, forapp: Binding<Forapp>) {
        _isConfirm = isConfirm
        _forapp = forapp
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let responseString = message.body as? String {
            
            //print(responseString)
                        
            do {
                // 解析 JSON 數據
                let json = try JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: []) as? [String : Any]
                //let code = json?["code"] as? Int
                //let message = json?["message"] as? String
                //print("code: \(String(describing: code))")
                //print("message: \(String(describing: message))")
                let data = json?["data"] as? [String: Any]
                //let response = data?["response"] as? String
                let tick = data?["tick"] as? String
                //print("response: \(String(describing: response))")
                //print("tick: \(String(describing: tick))")
                
                if(tick != nil){
                    //更新App勳章個數
                    print("Update notification counter. ")
                    GET_URLRequest_Forapp()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

//        self.isConfirm = true
    }
    
    // MARK: -拿取通知項目數
    func GET_URLRequest_Forapp() {
        let session = URLSession(configuration: .default)
        let user_id = CurrentUserID
        // 設定URL
//        let url = PocUrl +  "forapp?user_id=\(user_id)"
        let url = PocUrl +  "api/nilm09/forapp?user_id=\(user_id)"
        var request = URLRequest(url: URL(string: url)!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (GET Forapp)")
//            print(response)
//            print(data)
            
            // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                //let code = json?["code"] as? Int
                //let message = json?["message"] as? String
                //print("code: \(code)")
                //print("message: \(message)")
                
                let dataDict = json?["app"] as? [String: Any]
                //let userId = dataDict?["user_id"] as? String
                let user_advice_bt = dataDict?["user_advice_bt"] as? String
                let weekly_monthly_report_bth = dataDict?["weekly_monthly_report_bth"] as? String
                let manage_control_advice_bth = dataDict?["manage_control_advice_bth"] as? String
                //print("user_id: \(userId)")
                //print("user_advice_bt: \(user_advice_bt)")
                //print("weekly_monthly_report_bth: \(weekly_monthly_report_bth)")
                //print("manage_control_advice_bth: \(manage_control_advice_bth)")
                DispatchQueue.main.async {
                    self.forapp.User_advice_bt = Int(user_advice_bt!) ?? 0
                    self.forapp.Weekly_monthly_report_bth = Int(weekly_monthly_report_bth!) ?? 0
                    self.forapp.Manage_control_advice_bth = Int(manage_control_advice_bth!) ?? 0
                }
                print("GET Forapp Pass")
            } catch {
                print(error)
                }
        }
        task.resume()
    }
}

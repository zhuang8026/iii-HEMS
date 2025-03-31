//
//  ElectricityManageView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/3/6.
//

import SwiftUI
import WebKit

struct ElectricityManageWebUIView: View {
    @Binding var loginflag:Bool
    @State var error: Error? = nil
    @State private var shouldReload = false
    @State private var canGoBack = true
    
    var body: some View {
        VStack{
            ElectricityManageWebView(url: URL(string: "\(PocUrl)remote")!, loginflag: $loginflag, shouldReload: $shouldReload, canGoBack: $canGoBack)
            .onLoadStatusChanged {(loading, error) in
                if loading {
                    print("Loading…")
                }
                else {
                    print("Done loading.")
                }
            }
        }.onAppear{
            print("進入管理用電頁面")
            //重新讀取介面
            shouldReload = true
        }        
    }
}

struct ElectricityManageView_Previews: PreviewProvider {
    static var previews: some View {
        ElectricityManageWebUIView(loginflag: .constant(true))
    }
}



struct ElectricityManageWebView: UIViewRepresentable {
    let view = WKWebView()
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
//    var messageHandler: ElectricityManageMessageHandler
    @Binding var loginflag: Bool
    @Binding var shouldReload: Bool
    var delegate: WebViewDelegate = WebViewDelegate()  //超連結處理
    @Binding var canGoBack: Bool // 控制是否能返回上一頁
    
    func makeCoordinator() -> ElectricityManageWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        view.navigationDelegate = context.coordinator
//        view.configuration.userContentController.add(messageHandler, name: "ElectricityManageMessageHandler")
        
        // Load cookies into HTTPCookieStorage
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
                                
        view.load(URLRequest(url: url))
        view.navigationDelegate = delegate  //超連結委派處理
        
        // 新增左滑手勢識別功能
        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleSwipeGesture(_:)))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
        
        return view
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // you can access environment via context.environment here
        // Note that this method will be called A LOT
//        print("updateUIView")
        
        if shouldReload {
            view.reload()
            shouldReload = false
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
        let parent: ElectricityManageWebView
        
        init(_ parent: ElectricityManageWebView) {
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
             //重新導向登入頁面時
            if (webView.title! == "用戶登入")
            {
                //返回登入介面
                parent.loginflag = true
            }
            
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
            print("網頁讀取完成")
            
            if(!webView.url!.absoluteString.contains("remote"))
            {
                //返回登入介面
                parent.loginflag = true
            }
        }
        
        @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
            if gesture.direction == .right {
                print("上一頁")
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

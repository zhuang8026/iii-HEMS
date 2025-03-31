//
//  ElectricityTrackingWebView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/25.
//

import Foundation
import SwiftUI
import WebKit

struct ElectricityTrackingWebView: View {
    
    @Binding var loginflag:Bool
    @State var error: Error? = nil
    @State var isLogin: Bool = false
    @State private var shouldReload = false
    
    var body: some View {
        VStack{
            ElectricityTrackingWebWebView(url: URL(string: PocUrl)!, loginflag: $loginflag, shouldReload: $shouldReload)
            
            .onLoadStatusChanged {(loading, error) in
                if loading {
                    print("Loading…")
                }
                else {
                    print("Done loading.")
                }
            }
        }.onAppear{
            print("進入用電追蹤頁面(web)")
            //重新讀取介面
            shouldReload = true
        }
    }
}

//struct HomeEnergyReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeEnergyReportView(loginflag: .constant(true))
//    }
//}


struct ElectricityTrackingWebWebView: UIViewRepresentable {
    let view = WKWebView()
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    
    @Binding var loginflag: Bool
    @Binding var shouldReload: Bool
    
    func makeCoordinator() -> ElectricityTrackingWebWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        view.navigationDelegate = context.coordinator
//        view.configuration.userContentController.add(messageHandler, name: "HomeEnergyMessageHandler")
        
        // Load cookies into HTTPCookieStorage
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
        view.load(URLRequest(url: url))
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
    }
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: ElectricityTrackingWebWebView
        
        init(_ parent: ElectricityTrackingWebWebView) {
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
//            print("網頁讀取完成")
//            print(webView.url)
            if(webView.url!.absoluteString.contains("login"))
            {
                //返回登入介面
                parent.loginflag = true
            }
        }
    }
}

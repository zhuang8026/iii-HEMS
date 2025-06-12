//
//  GraphicsAlert.swift
//  Energy-Active
//
//  Created by IIIai on 2023/8/1.
//

import SwiftUI
import WebKit

class GraphicsAlertManager : ObservableObject {
    @Published var showAlert = false
}

// MARK: - GraphicsAlert View
extension View {
    func environmentGraphicsAlertView(loginflag: Binding <Bool>, showAlert: Binding <Bool>) -> some View {
            self.modifier(GraphicsAlertModifier(loginflag: loginflag, showAlert: showAlert)
        )
    }
}

// MARK: - GraphicsAlertModifier

struct GraphicsAlertModifier : ViewModifier {
    @EnvironmentObject var electricityGraphicsAlertManager : GraphicsAlertManager
    @Binding var loginflag:Bool
    @Binding var showAlert: Bool
    @State var shouldReload = false
    
    func body(content: Content) -> some View {
    
        ZStack { content

            if showAlert {
                withAnimation {
                    graphicsAlert()
                }
            }
        }
    }
}

// MARK: - GraphicsAlert methods

extension GraphicsAlertModifier {
    
    private func graphicsAlert() -> some View {
        
        ZStack{
            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showAlert = false
                }
                    
            ZStack {
                
                ZStack {
                    GraphicsWebView(url: URL(string: "\(PocUrl)graphics?userId=\(CurrentUserID)")!, loginflag: $loginflag, shouldReload: $shouldReload)
                        .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
                        .rotationEffect(.degrees(90))
                }
            }
            .animation(.default, value: shouldReload)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        if showAlert {
                            Button(action: {
                                withAnimation {
                                    showAlert = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0))
                            }
                            .padding()
                            .zIndex(1) //確保按鈕在最上層
                        }
                    }
                }
            )
            .padding(.horizontal, 12)
            
        }
        .onAppear{
            print("開啟 GraphicsAlert 頁面")
        }
    }
}



// MARK: - GraphicsAlert 舊版
//struct GraphicsAlert: View {
//    @Binding var loginflag:Bool
//    @Binding var showAlert: Bool
//    @State var shouldReload = false
//    
//    var body: some View {
//        
//        ZStack{
//            
////            Color.init(hex: "#e0e0e0", alpha: 0.7)
//            Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showAlert = false
//                }
//
////            VStack {
////                ZStack {
////                    ScrollView(.horizontal) {
////                        HStack {
////                            GraphicsWebView(url: URL(string: "\(PocUrl)graphics?userId=\(CurrentUserID)")!, loginflag: $loginflag, shouldReload: $shouldReload)
////                                .frame(width: UIScreen.main.bounds.width * 1.2)
////                            
////                            VStack{
////                                
////                                if showAlert {
////                                    Button(action: {
////                                        withAnimation {
////                                            showAlert = false
////                                        }
////                                    }) {
////                                        Image(systemName: "xmark")
////                                            .resizable()
////                                            .frame(width: 25, height: 25)
////                                            .foregroundColor(Color(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0))
////                                    }
////                                    .padding()
////                                    .zIndex(1) //確保按鈕在最上層
////                                }
////                                
////                                Spacer()
////                            }
////                        }
////                    }
////                }
////                Spacer()
////            }
//                    
//            ZStack {
//                
//                ZStack {
//                    GraphicsWebView(url: URL(string: "\(PocUrl)graphics?userId=\(CurrentUserID)")!, loginflag: $loginflag, shouldReload: $shouldReload)
//                        .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
//                        .rotationEffect(.degrees(90))
//                }
//            }
//            .animation(.default, value: shouldReload)
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//            .background(Color.white)
//            .cornerRadius(10)
//            .overlay(
//                VStack{
//                    Spacer()
//                    HStack{
//                        Spacer()
//                        if showAlert {
//                            Button(action: {
//                                withAnimation {
//                                    showAlert = false
//                                }
//                            }) {
//                                Image(systemName: "xmark")
//                                    .resizable()
//                                    .frame(width: 25, height: 25)
//                                    .foregroundColor(Color(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0))
//                            }
//                            
//                            .padding()
//                            .zIndex(1) //確保按鈕在最上層
//                        }
//                    }
//                }
//            )
//            .padding(.horizontal, 12)
//        }
//        .onAppear{
//            print("開啟 GraphicsAlert 頁面")
//            // MARK: 從這裡開始先刷新界面必備資料
////            shouldReload = true
//        }
//    }
//}

struct GraphicsWebView: UIViewRepresentable {
    let view = WKWebView()
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    @Binding var loginflag: Bool
    @Binding var shouldReload: Bool
    
    func makeCoordinator() -> GraphicsWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        view.navigationDelegate = context.coordinator
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
        let parent: GraphicsWebView
        
        init(_ parent: GraphicsWebView) {
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
                        
            if navigationAction.navigationType == .formResubmitted {
                    if let url = navigationAction.request.url,
                        UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
//                        print(url)
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
//            let js = "document.body.style.zoom = 0.7;" // 表示縮放比例
//            webView.evaluateJavaScript(js, completionHandler: nil)
            
            
            
        }
    }
}

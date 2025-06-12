//
//  CustomerServiceView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/3/6.
//

import SwiftUI
import WebKit

struct CustomerServiceView: View {
    
    @Binding var loginflag:Bool
    @Binding var robotIconDisplay:Bool
    @State var isLoaded = true
    
    var body: some View {
        VStack (spacing: 0){
            NavigationView {
                ZStack{
                    BackgroundColor.ignoresSafeArea(.all, edges: .top)
                    VStack(spacing: 1) {
                        VStack{
                            Image("top-title").resizable().scaledToFit()
                                .foregroundColor(.clear)
                                .frame(width: 177.0, height: 27)
                        }.frame(height: 50.0)
                        
                        NavigationLink {
                            //                            UserAccountChangeView(loginflag: $loginflag)
                            UserPasswordChangeView(loginflag: $loginflag)
                        } label: {
                            Text("密碼變更")
                                .font(.custom("NotoSansTC-Medium", size: 20))
                                .foregroundColor(Color.white)
                                .frame( width: UIScreen.main.bounds.width, height: 60, alignment: .center)
                                .background(Color(red: 40.0 / 255.0, green: 180.0 / 255.0, blue: 179.0 / 255.0))
                        }
                        .padding(.top)
                        
                        NavigationLink {
                            ModificationDataView(loginflag: $loginflag)
                        } label: {
                            Text("資料修改")
                                .font(.custom("NotoSansTC-Medium", size: 20))
                                .foregroundColor(Color.white)
                                .frame( width: UIScreen.main.bounds.width, height: 60, alignment: .center)
                                .background(Color(red: 93.0 / 255.0, green: 194.0 / 255.0, blue: 184.0 / 255.0))
                        }
                        
                        NavigationLink {
                            BindAppliancesView(loginflag: $loginflag)
                        } label: {
                            Text("綁定電器")
                                .font(.custom("NotoSansTC-Medium", size: 20))
                                .foregroundColor(Color.white)
                                .frame( width: UIScreen.main.bounds.width, height: 60, alignment: .center)
                                .background(Color(red: 40.0 / 255.0, green: 180.0 / 255.0, blue: 179.0 / 255.0))
                        }
                        
                        Button {
                            print("點擊登出")
                            self.isLoaded = false
                            UserDefaults.standard.set("", forKey: "user_password")
                            
                            startLoadingTimer()
                            
                        } label: {
                            Text("登出")
                                .font(.custom("NotoSansTC-Medium", size: 20))
                                .foregroundColor(Color.white)
                                .frame( width: UIScreen.main.bounds.width, height: 60, alignment: .center)
                                .background(Color(red: 61.0 / 255.0, green: 102.0 / 255.0, blue: 143.0 / 255.0))
                        }

                        Text("\(version)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.vertical, 10)
                        //                        // MARK: 測試異常用, 正式時請註解
                        //                        Button {
                        //                            print("測試異常")
                        //                            POST_URLRequest_test_abnormal_consumption()
                        //
                        //                        } label: {
                        //                            Text("測試異常")
                        //                                .font(.custom("NotoSansTC-Medium", size: 20))
                        //                                .foregroundColor(Color.white)
                        //                                .frame( width: UIScreen.main.bounds.width, height: 60, alignment: .center)
                        //                                .background(Color(red: 61.0 / 255.0, green: 102.0 / 255.0, blue: 143.0 / 255.0))
                        //                        }
                        
                        
                        Spacer()
                      
                    }
                    
                    if(!self.isLoaded){
                        Color.light_green.opacity(0.85) // 透明磨砂黑背景
                            .edgesIgnoringSafeArea(.all) // 覆蓋整個畫面
                        Loading(text: "資料載入中...",color: Color.g_blue)
    
//                        Color(white: 0.0, opacity: 0.4).edgesIgnoringSafeArea(.all)
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: Color.init(hex: "#6a717d")))
//                            .scaleEffect(2)
                    }
                    
                }.navigationBarTitle("")
            }
            Spacer()
        }
        .onAppear{
            
            print("進入用帳戶服務頁面")
            // MARK: 機器人圖示為關閉
            self.robotIconDisplay = false
        }
    }
    
    
    private func startLoadingTimer() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.isLoaded = true
            loginflag = true
            timer.invalidate()
        }
    }
    
    //    func POST_URLRequest_test_abnormal_consumption(){
    //
    //        let session = URLSession(configuration: .default)
    //        // 設定URL
    //        let url = "http://15.165.147.172:8885/abnormal_consumption"
    //        var request = URLRequest(url: URL(string: url)!)
    //
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.httpMethod = "POST"
    //
    //        let user_id = "billdavid50814@gmail.com"
    //        let report_time = "2024-11-01 10:00:00"
    //        let anom_class = "1"
    //
    //        let postData = ["user_id":user_id,"report_time":report_time,"anom_class":anom_class]
    //        do {
    //            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
    //            request.httpBody = jsonData
    //        } catch {
    //
    //        }
    //
    //        // 接收回傳的task
    //        let task = session.dataTask(with: request) {(data, response, error) in
    //            do {
    //                print("連線到伺服器 (POST abnormal_consumption)")
    //                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
    //                //print(response)
    //                //print(json)
    //
    //                print("POST abnormal_consumption Pass")
    //            } catch {
    //                print(error)
    //                return
    //            }
    //        }
    //        task.resume()
    //    }
}

//struct CustomerServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomerServiceView(loginflag: .constant(true))
//    }
//}

struct UserAccountChangeView: View {
    
    @Binding var loginflag: Bool
    let user_id  = CurrentUserID
    //    let Ntpc3Url : String = "https://ntpc3.lowcarbon-hems.org.tw/"
    @State private var textFields: [TextFieldModel] = [TextFieldModel()]
    @State var userName:String = ""
    
    var body: some View {
        
        ZStack{
            //            Color.init(hex: "#e9ecd9", alpha: 1.0)
            
            Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0).ignoresSafeArea(.all, edges: .top)
            VStack{
                Text("帳號變更").font(.custom("NotoSansTC-Medium", size: 20))
                    .foregroundColor(DarkGrayCustomizeColor)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
                    .padding(.top, 15)
                
                Text("帳號變更").font(.custom("NotoSansTC-Medium", size: 14))
                    .foregroundColor(DarkGrayCustomizeColor)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                    .padding(.horizontal).padding(.top, 27)
                
                TextField("請輸入用戶名稱", text: $userName)
                    .font(.custom("NotoSansTC-Medium", size: 18))//.font(.system(size: 16))
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 52, alignment: .leading)
                    .padding(.horizontal, 13)
                
                
                Group{
                    Text("行動登入電話號碼").font(.custom("NotoSansTC-Medium", size: 14))
                        .foregroundColor(DarkGrayCustomizeColor)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 13).padding(.top, 18)
                    
                    
                    VStack{
                        ForEach(textFields.indices, id: \.self) { index in
                            HStack {
                                TextField("請輸入行動電話", text: self.$textFields[index].text)
                                    .font(.custom("NotoSansTC-Medium", size: 18))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(height: 52, alignment: .leading)
                                    .padding(.leading, 13)
                                
                                if(index == 0){
                                    Button(action: {
                                        withAnimation {
                                            self.addTextField()
                                        }
                                    }, label: {
                                        Image("icon-add").resizable().scaledToFit().frame(width: 40, height: 40)
                                    })
                                }
                                else{
                                    Button(action: {
                                        withAnimation {
                                            self.removeTextField(at: index)
                                        }
                                    }, label: {
                                        Image("icon-minus").resizable().scaledToFit().frame(width: 40, height: 40)
                                    })
                                }
                                
                            }
                        }
                    }//.padding(.horizontal, 13)
                }
                
                Spacer()
                
                HStack{
                    
                    NavigationLink {
                        //                    print("點擊密碼變更")
                        UserPasswordChangeView(loginflag: $loginflag)
                    } label: {
                        Text("密碼變更").font(.custom("NotoSansTC-Medium", size: 14))//.font(.system(size: 16))
                            .foregroundColor(DarkGrayCustomizeColor)
                            .padding(10)
                            .frame(width: 160.0, height: 40.0)
                            .background(GreyCustomizeColor)
                            .cornerRadius(40.0)
                            .shadow(color: Color(white: 0.0, opacity: 0.16), radius: 3.0, x: 0.0, y: 3.0)
                    }
                    
                    Spacer()
                    
                    Button {
                        let phoneNum = textFields.dropFirst().reduce(into: textFields.first?.text ?? "") { result, person in
                            result += " " + person.text
                        }
                        PATCH_URLRequest_user_setting(userName,"nickName")
                        PATCH_URLRequest_user_setting(phoneNum,"allowedPhones")
                        print("點擊儲存設定")
                    } label: {
                        Text("儲存設定").font(.custom("NotoSansTC-Medium", size: 14))//.font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(width: 160.0, height: 40.0)
                            .background(GreenCustomizeColor)
                            .cornerRadius(40.0)
                            .shadow(color: Color(white: 0.0, opacity: 0.16), radius: 3.0, x: 0.0, y: 3.0)
                        
                    }
                }.padding(.horizontal, 13).padding(.bottom, 15)
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .aspectRatio(351/428, contentMode: .fit)
            .background(BackgroundColor)
            .cornerRadius(5)
            .padding(.horizontal, 12)
            .navigationBarTitle("")
        }.onTapGesture {
            //            UIApplication.shared.keyWindow?.endEditing(true)
            endEditing()
        }
    }
    
    func endEditing() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        window.endEditing(true)
    }
    
    func addTextField() {
        if(textFields.count <= 4){
            textFields.append(TextFieldModel())
        }
    }
    
    func removeTextField(at index: Int) {
        textFields.remove(at: index)
    }
    
    // MARK: -管理用電-排程管理-編輯
    func PATCH_URLRequest_user_setting(_ data : String, _ type : String){
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: type, value: data),
        ]
        let query = components.percentEncodedQuery ?? ""
        let data = Data(query.utf8)
        
        
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token")!
        let url = PocUrl + "api/main/user-setting"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        request.httpBody = data
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (PATCH user-setting) \(type)")
            //                print(response)
            //                print(data)
            
            //                // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //                    print(json)
                if(code == 200){
                    //                        print(json)
                }
                else if(code == 4002){
                    //back to login
                    DispatchQueue.main.async {
                        loginflag = true
                    }
                }
                else{
                    //back to login
                    DispatchQueue.main.async {
                        loginflag = true
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct UserPasswordChangeView: View {
    @Binding var loginflag: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let user_id  = CurrentUserID
    @State private var oldPassword:String = ""
    @State private var newPassword:String = ""
    @State private var confirmNewPassword:String = ""
    @State private var isOldPasswordValid = false
    @State private var isPasswordValid = false
    @State private var isConfirmedPasswordValid = false
    @State private var oldPasswordErrorMessage = ""
    @State private var passwordErrorMessage = ""
    @State private var confirmedPasswordErrorMessage = ""
    @State private var isOldSecure = true
    @State private var isNewSecure = true
    @State private var isConfirmedSecure = true
    @State private var showAlert = false
    @State private var alertTitleMessage : String = ""
    @State private var alertMessage : String = ""
    
    var body: some View {
        
        ZStack{
            Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0).ignoresSafeArea(.all, edges: .top)
            
            VStack(spacing: 0){
                Text("密碼變更").font(.custom("NotoSansTC-Medium", size: 20))
                    .foregroundColor(DarkGrayCustomizeColor)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
                    .padding(.top, 15)
                
                //                Text("密碼為8-12字元長度的符號英文字母，以及數字混合字串")
                Text("必須包含大小寫英文字母、數字和特殊符號")
                    .font(.custom("NotoSansTC-Medium", size: 16))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 13).padding(.top, 15)
                
                Group{
                    HStack(spacing: 0){
                        Text("*").font(.system(size: 24)).foregroundColor(.red)
                        Text("原密碼").font(.custom("NotoSansTC-Medium", size: 14))
                            .foregroundColor(DarkGrayCustomizeColor)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                    .padding(.horizontal).padding(.top, 15)
                    
                    ZStack {
                        if isOldSecure {
                            SecureField("請輸入原密碼", text: $oldPassword, onCommit: validateOldPassword)
                            
                        } else {
                            TextField("請輸入原密碼", text: $oldPassword, onCommit: validateOldPassword)
                        }
                        
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                isOldSecure.toggle()
                            }) {
                                Image(systemName: isOldSecure ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }.padding(.trailing, 8)
                        }
                    }
                    .font(.custom("NotoSansTC-Medium", size: 16))
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 52, alignment: .leading)
                    .padding(.horizontal, 13)
                    
                    Text(oldPasswordErrorMessage)
                        .font(.custom("NotoSansTC-Medium", size: 12))
                        .foregroundColor(.red)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                        .padding(.horizontal, 13)
                    
                }
                Group{
                    HStack(spacing: 0){
                        Text("*").font(.system(size: 24)).foregroundColor(.red)
                        Text("新密碼").font(.custom("NotoSansTC-Medium", size: 14))
                            .foregroundColor(DarkGrayCustomizeColor)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 13)
                    
                    
                    ZStack {
                        if isNewSecure {
                            SecureField("請輸入新密碼", text: self.$newPassword, onCommit: validatePassword)
                        } else {
                            TextField("請輸入新密碼", text: self.$newPassword, onCommit: validatePassword)
                        }
                        
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                isNewSecure.toggle()
                            }) {
                                Image(systemName: isNewSecure ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }.padding(.trailing, 8)
                        }
                    }
                    .font(.custom("NotoSansTC-Medium", size: 16))
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 52, alignment: .leading)
                    .padding(.horizontal, 13)
                    
                    Text(passwordErrorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                        .padding(.horizontal, 13)
                    
                }
                Group{
                    HStack(spacing: 0){
                        Text("*").font(.system(size: 24)).foregroundColor(.red)
                        Text("確認新密碼").font(.custom("NotoSansTC-Medium", size: 14))
                            .foregroundColor(DarkGrayCustomizeColor)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 13)
                    
                    ZStack {
                        if isConfirmedSecure {
                            SecureField("請再次輸入新密碼", text: self.$confirmNewPassword, onCommit: validateConfirmedPassword)
                        } else {
                            TextField("請再次輸入新密碼", text: self.$confirmNewPassword, onCommit: validateConfirmedPassword)
                        }
                        
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                isConfirmedSecure.toggle()
                            }) {
                                Image(systemName: isConfirmedSecure ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }.padding(.trailing, 8)
                        }
                    }
                    .font(.custom("NotoSansTC-Medium", size: 16))
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 52, alignment: .leading)
                    .padding(.horizontal, 13)
                    
                    Text(confirmedPasswordErrorMessage)
                        .font(.custom("NotoSansTC-Medium", size: 12))
                    //                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .leading)
                        .padding(.horizontal, 13)
                }
                
                HStack{
                    Button {
                        print("點擊儲存設定")
                        PATCH_URLRequest_password_reset(oldPassword, newPassword, confirmNewPassword)
                    } label: {
                        Text("儲存設定").font(.custom("NotoSansTC-Medium", size: 14))//.font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 40.0)
                            .background(GreenCustomizeColor)
                            .cornerRadius(40.0)
                            .shadow(color: Color(white: 0.0, opacity: 0.16), radius: 3.0, x: 0.0, y: 3.0)
                    }
                }.padding()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .aspectRatio(351/428, contentMode: .fit)
            .background(BackgroundColor)
            .cornerRadius(5)
            .padding(.horizontal, 12)
            
            .navigationBarTitle("")
        }.onTapGesture {
            //            UIApplication.shared.keyWindow?.endEditing(true)
            endEditing()
        }
        .alert(isPresented: self.$showAlert, content: {
            return Alert(title: Text(alertTitleMessage), message: Text(alertMessage), dismissButton: .default(Text("確定"), action: {
                //執行的程式
                UserDefaults.standard.set("", forKey: "user_password")
                self.loginflag = true
            }))
        }
        )
    }
    
    func endEditing() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        window.endEditing(true)
    }
    
    func PATCH_URLRequest_password_reset(_ oldPassword : String, _ newPassword : String, _ confirmNewPassword : String){
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "oriPassword", value: oldPassword),
            URLQueryItem(name: "newPassword", value: newPassword),
            URLQueryItem(name: "reNewPassword", value: confirmNewPassword),
        ]
        let query = components.percentEncodedQuery ?? ""
        let data = Data(query.utf8)
        
        
        let session = URLSession(configuration: .default)
        let token = UserDefaults.standard.string(forKey: "access_token")!
        let url = PocUrl + "api/main/password-reset"
        var request = URLRequest(url: URL(string: url)!)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        request.httpBody = data
        // 接收回傳的task
        let task = session.dataTask(with: request) {(data, response, error) in
            print("連線到伺服器 (PATCH password-reset)")
            //                print(response)
            //                print(data)
            
            //                // MARK: 解析json
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                let code : Int = json?["code"] as? Int ?? 0
                //                    print(json)
                if(code == 200){
                    self.alertTitleMessage = "變更成功"
                    self.alertMessage = ""
                    
                    self.showAlert = true
                    print("PATCH password-reset Pass")
                }
                else if(code == 4002){
                    //back to login
                    DispatchQueue.main.async {
                        loginflag = true
                    }
                }
                else{
                    //舊密碼錯誤
                    isOldPasswordValid = false
                    oldPasswordErrorMessage = "原密碼輸入錯誤"
                    let message = json?["message"] as? String ?? "null"
                    self.alertTitleMessage = "錯誤"
                    self.alertMessage = message
                    self.showAlert = true
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    private func validateOldPassword() {
        if oldPassword == ""{
            isOldPasswordValid = false
            oldPasswordErrorMessage = "請輸入原密碼"
        }
    }
    
    private func validatePassword() {
        
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,12}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        
        if passwordPredicate.evaluate(with: newPassword) {
            isPasswordValid = true
            passwordErrorMessage = ""
        } else {
            isPasswordValid = false
            passwordErrorMessage = "密碼為8-12字元長度的符號英文字母，以及數字混合字串"
        }
        
        if newPassword == ""{
            isPasswordValid = false
            passwordErrorMessage = "請輸入新密碼"
            
        }
    }
    
    private func validateConfirmedPassword() {
        if confirmNewPassword != newPassword {
            isConfirmedPasswordValid = false
            confirmedPasswordErrorMessage = "新密碼不一致"
        } else {
            isConfirmedPasswordValid = true
            confirmedPasswordErrorMessage = ""
        }
        
        if confirmNewPassword == ""{
            isConfirmedPasswordValid = false
            confirmedPasswordErrorMessage = "請再次輸入新密碼"
            
        }
    }
}

struct BottomLineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack() {
            configuration
            Rectangle()
                .frame(height: 2, alignment: .bottom)
                .foregroundColor(Color.secondary)
        }
    }
}

struct TextFieldModel: Identifiable {
    var id = UUID()
    var text = ""
}



struct ModificationDataView: View {
    
    @Binding var loginflag:Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var error: Error? = nil
    @State var isLogin: Bool = false
    @State var isConfirm:Bool = false
    @State var shouldReload = false
    @State private var canGoBack = true
    
    var body: some View {
        VStack{
            ModificationDataWebView(url: URL(string: "\(PocUrl)survey?user_id=\(CurrentUserID)")!, messageHandler: ConfirmHandler(isConfirm: $isConfirm), loginflag: $loginflag, shouldReload: $shouldReload, canGoBack: $canGoBack)
                .onLoadStatusChanged {(Loading, error) in
                    if Loading {
                        print("Loading……")
                    }
                }
        }
        .onAppear{
            print("進入資料修改頁面")
            //重新讀取介面
            self.shouldReload = true
            
        }
        .onChange(of: isConfirm) { value in
            if value{
                //                print("回上一頁")
                isConfirm = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ModificationDataWebView: UIViewRepresentable {
    let view = WKWebView()
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var messageHandler: ConfirmHandler
    @Binding var loginflag: Bool
    @Binding var shouldReload: Bool
    var delegate: WebViewDelegate = WebViewDelegate()  //超連結處理
    @Binding var canGoBack: Bool // 控制是否能返回上一頁
    
    func makeCoordinator() -> ModificationDataWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        view.navigationDelegate = context.coordinator
        view.configuration.userContentController.add(messageHandler, name: "ConfirmHandler")
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
        let parent: ModificationDataWebView
        
        init(_ parent: ModificationDataWebView) {
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
                self.parent.loginflag = true
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
            //            print("網頁讀取完成\(webView.url!)")
            if(!webView.url!.absoluteString.contains("survey"))
            {
                //返回登入介面
                self.parent.loginflag = true
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
                            if(this.recordedUrl.includes("que_info"))
                            {
                                //攔截response訊息
                                var self = this;
                                this.onreadystatechange = function() {
                                    if (self.readyState === 4 && self.status === 200) {
                                        //window.webkit.messageHandlers.ConfirmHandler.postMessage(self.responseText);
                                        window.webkit.messageHandlers.ConfirmHandler.postMessage(this.recordedUrl);
                                        //var obj = JSON.parse(self.responseText);
                                        //window.webkit.messageHandlers.ConfirmHandler.postMessage(obj.message);
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
                    
                }
            } )
            
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



class ConfirmHandler: NSObject, WKScriptMessageHandler {
    @Binding var isConfirm: Bool
    
    init(isConfirm: Binding<Bool>) {
        _isConfirm = isConfirm
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //        print(message.body)
        self.isConfirm = true
    }
    
    
}

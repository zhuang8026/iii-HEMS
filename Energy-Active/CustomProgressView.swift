//
//  CustomProgressView.swift
//  Energy-Active
//
//  Created by IIIai on 2023/5/11.
//

import Foundation
import SwiftUI

struct CustomProgressView: View {
    var progress: Double
    var progressColor: Color
    var showProgressText = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 20)
                        .foregroundColor(Color.init(hex: "#f3f3f3", alpha: 1.0))
                        .background(Color.clear)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: (CGFloat(self.getProgress()) * geometry.size.width) / 100,
                               height: 20)
                        .foregroundColor(progressColor)
                        .background(Color.clear)
                        
                }
            }
            
            // Progress text will be added here
//            if showProgressText {
//                Text("\(Int(getProgress()))%")
//                    .padding(.top, 20)
//                    .font(.callout)
//            }
        }
        .frame(height: 10)
//        .padding(12)
    }
    
    
    func getProgress() -> Double {
        if (0...100).contains(progress) {
            return progress
        } else {
            return progress < 0 ? 0 : 100
        }
    }
}

struct CustomCircularProgressView: View {
    
    let viewSize: CGSize
    
    let progressText: Double
    let progress: Double
    let dotPosition = 0.833
    let previous_year_date :Int
    
    
    var body: some View {
        ZStack {
            VStack(spacing:0){
                Text("本月累積").font(.custom("NotoSansTC-Medium", size: 24)).foregroundColor(Color.init(hex: "#1ca3a6", alpha: 1.0))
                Text("\(progressText, specifier: "%.0f")").font(.custom("NotoSansTC-Bold", size: 50)).bold().foregroundColor(Color.init(hex: "#1ca3a6", alpha: 1.0))
                + Text(" 度").font(.custom("NotoSansTC-Medium", size: 26)).foregroundColor(Color.init(hex: "#1ca3a6", alpha: 1.0))
                
                HStack{
                    //代表沒有取到值
                    if(previous_year_date != -9999)
                    {
                        let a = Text("較去年同月")
                        let b = previous_year_date >= 0 ? Text("多") : Text("少")
                        let c = Text(String(abs(previous_year_date)))
                        let d = Text("度")
                        
                        Text("\(a)\(b)\(c)\(d)")
                            .font(.custom("NotoSansTC-Medium", size: 18.0))
                            .foregroundColor(Color(red: 88.0 / 255.0, green: 92.0 / 255.0, blue: 141.0 / 255.0))
                    }
                    else{
                        EmptyView()
                    }
                }.padding(.top, 10)
            }
            Circle()
                .stroke(
                    Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0),
                    lineWidth: 20
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(red: 93.0 / 255.0, green: 194.0 / 255.0, blue: 184.0 / 255.0),
                    lineWidth: 20
                )
                .rotationEffect(.degrees(-90))
            
            // 點的距離為外框的1/2
            if dotPosition == 0.833 {
                let dotAngle = 360 * dotPosition
                let dotX = sin(Angle(degrees: -dotAngle).radians)
                let dotY = cos(Angle(degrees: -dotAngle).radians)
                
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(Color.black)
                    .offset(x: CGFloat(dotX) * (viewSize.height / 2), y: CGFloat(dotY) * (viewSize.width / 2))
                    .rotationEffect(.degrees(180))
            }
        }
    }
}


//struct CustomProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomProgressView(progress: 40, progressColor: .green)
//            .previewLayout(.sizeThatFits)
//    }
//}

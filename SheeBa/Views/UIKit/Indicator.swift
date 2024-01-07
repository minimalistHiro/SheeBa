//
//  Indicator.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/10.
//

import SwiftUI

struct Indicator: UIViewRepresentable {
    
    @Binding var onIndicator: Bool             // インジケーターが進行中か否か
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        //UIKitのビューを作成
        return UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
            if onIndicator {
                //進行させる
                uiView.startAnimating()
                
            } else {
                //進行させない
                uiView.stopAnimating()
            }
        }
}

struct ScaleEffectIndicator: View {
    
    @Binding var onIndicator: Bool
    
    var body: some View {
        Indicator(onIndicator: $onIndicator)
            .scaleEffect(3)
    }
}

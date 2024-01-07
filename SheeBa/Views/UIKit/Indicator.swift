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
        return UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if onIndicator {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

// 3倍に拡大したインジケーター
struct ScaleEffectIndicator: View {
    
    @Binding var onIndicator: Bool
    
    var body: some View {
        Indicator(onIndicator: $onIndicator)
            .scaleEffect(3)
    }
}

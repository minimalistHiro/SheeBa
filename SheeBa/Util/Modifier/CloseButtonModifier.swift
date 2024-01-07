//
//  CloseButtonModifier.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/30.
//

import SwiftUI

// 独自実装した閉じるボタン
struct CloseButtonModifier: ViewModifier {
    
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "multiply")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .bold()
                            .foregroundColor(.black)
                    }
                }
            }
    }
}

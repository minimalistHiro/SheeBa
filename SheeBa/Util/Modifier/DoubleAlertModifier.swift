//
//  DoubleNormalAlertModifier.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/11/20.
//

import SwiftUI

struct DoubleAlertModifier: ViewModifier {
    
    let title: String
    @Binding var isShowAlert: Bool
    let message: String
    let buttonText: String
    let didAction: () -> ()
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isShowAlert) {
                Button {
                    didAction()
                } label: {
                    Text(buttonText)
                }
                Button(role: .cancel) {
                    isShowAlert = false
                } label: {
                    Text("キャンセル")
                }
            } message: {
                Text(message)
            }
    }
}

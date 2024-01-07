//
//  TripleAlertModifier.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/09.
//

import SwiftUI

struct TripleAlertModifier: ViewModifier {
    
    let title: String
    @Binding var isShowAlert: Bool
    let message: String
    let buttonText: String
    let destructiveButtonText: String
    let didAction: () -> ()
    let didDestructiveAction: () -> ()
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isShowAlert) {
                Button {
                    didAction()
                } label: {
                    Text(buttonText)
                }
                Button(role: .destructive) {
                    didDestructiveAction()
                } label: {
                    Text(destructiveButtonText)
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

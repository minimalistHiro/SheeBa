//
//  AlertModifier.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/16.
//

import SwiftUI

struct SingleAlertModifier: ViewModifier {
    
    let title: String
    @Binding var isShowAlert: Bool
    let message: String
    let didAction: () -> ()
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isShowAlert) {
                Button {
                    didAction()
                } label: {
                    Text("OK")
                }
            } message: {
                Text(message)
            }
    }
}

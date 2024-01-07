//
//  BackButtonModifier.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/15.
//

import SwiftUI

// 独自実装した戻るボタン
struct BackButtonModifier: ViewModifier {
    
    @Environment(\.dismiss) var dismiss
    // スワイプで戻る動作に使用する変数
    @GestureState private var dragOffset: CGSize = .zero
    private let edgeWidth: CGFloat = 50             // 最小スワイプ幅
    private let baseDragWidth: CGFloat = 30         // スワイプ開始x座標
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .bold()
                            .foregroundColor(.black)
                    }
                }
            }
            .highPriorityGesture(
                // スワイプで戻る動作
                DragGesture().updating($dragOffset) { value, _, _ in
                    if value.startLocation.x < edgeWidth && value.translation.width > baseDragWidth {
                        dismiss()
                    }
                }
            )
    }
}

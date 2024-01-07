//
//  AlertBackButtonModifier.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/11.
//

import SwiftUI

// 独自実装したアラート付き戻るボタン
struct AlertBackButtonModifier: ViewModifier {
    
    let didAction: () -> ()
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
                        didAction()
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
    }
}

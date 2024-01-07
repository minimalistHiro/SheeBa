//
//  GetPointView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/31.
//

import SwiftUI

struct GetPointView: View {
    
    @Environment(\.dismiss) var dismiss
    let chatUser: ChatUser?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // トップ画像
                HStack(spacing: 15) {
                    if let image = chatUser?.profileImageUrl {
                        if image == "" {
                            Icon.CustomCircle(imageSize: .medium)
                        } else {
                            Icon.CustomWebImage(imageSize: .medium, image: image)
                        }
                    } else {
                        Icon.CustomCircle(imageSize: .large)
                    }
                    Text(chatUser?.username ?? "")
                        .font(.title3)
                        .bold()
                }
                
                HStack {
                    Text("1")
                        .font(.system(size: 70))
                        .bold()
                    Text("pt")
                        .font(.title)
                }
                
                Text("ゲット!")
                    .font(.system(size: 30))
                    .bold()
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    CustomCapsule(text: "戻る", imageSystemName: nil, foregroundColor: .black, textColor: .white, isStroke: false)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GetPointView(chatUser: nil)
}

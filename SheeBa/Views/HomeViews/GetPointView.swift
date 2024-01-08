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
    let getPoint: String
    let isSameStoreScanError: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // トップ画像
                VStack {
                    if let image = chatUser?.profileImageUrl, image != "" {
                        Icon.CustomWebImage(imageSize: .large, image: image)
                    } else {
                        Icon.CustomCircle(imageSize: .large)
                    }
                    Text(chatUser?.username ?? "")
                        .font(.title2)
                        .bold()
                        .padding()
                }
                
                Spacer()
                
                if isSameStoreScanError {
                    Text("このQRコードは後日0時に有効になります。")
                        .bold()
                        .padding()
                } else {
                    HStack {
                        Text(getPoint)
                            .font(.system(size: 70))
                            .bold()
                        Text("pt")
                            .font(.title)
                    }
                    
                    Text("ゲット!")
                        .font(.system(size: 30))
                        .bold()
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    CustomCapsule(text: "戻る", imageSystemName: nil, foregroundColor: .black, textColor: .white, isStroke: false)
                }
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GetPointView(chatUser: nil, getPoint: "1", isSameStoreScanError: false)
}

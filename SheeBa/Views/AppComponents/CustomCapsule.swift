//
//  CapsuleButton.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/11/28.
//

import SwiftUI

struct CustomCapsule: View {
    
    let text: String
    let imageSystemName: String?
    let foregroundColor: Color
    let textColor: Color
    let isStroke: Bool
    
    // 各種サイズ
    let frameHeight: CGFloat = 50
    let imageFrameWidth: CGFloat = 20
    let paddingVertical: CGFloat = 10
    let paddingHorizontal: CGFloat = 40
    
    var body: some View {
        if isStroke {
            Capsule()
                .stroke(Color.black, lineWidth: 3)
                .foregroundStyle(foregroundColor)
                .frame(height: frameHeight)
                .overlay(alignment: .center) {
                    HStack {
                        if let image = imageSystemName {
                            Image(systemName: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageFrameWidth)
                                .foregroundStyle(.white)
                        }
                        Text(text)
                            .foregroundStyle(textColor)
                            .padding(.vertical, paddingVertical)
                            .font(.headline)
                            .bold()
                    }
                }
                .padding(.horizontal, paddingHorizontal)
        } else {
            Capsule()
                .foregroundStyle(foregroundColor)
                .frame(height: frameHeight)
                .overlay(alignment: .center) {
                    HStack {
                        if let image = imageSystemName {
                            Image(systemName: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageFrameWidth)
                                .foregroundStyle(.white)
                        }
                        Text(text)
                            .foregroundStyle(textColor)
                            .padding(.vertical, paddingVertical)
                            .font(.headline)
                            .bold()
                    }
                }
                .padding(.horizontal, paddingHorizontal)
        }
    }
}

#Preview {
    CustomCapsule(text: "QRコードで送る",
                  imageSystemName: "qrcode",
                  foregroundColor: .black,
                  textColor: .white,
                  isStroke: false)
}

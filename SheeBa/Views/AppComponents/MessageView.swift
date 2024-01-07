//
//  MessageView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/11/22.
//

import SwiftUI

struct MessageView {
    
    // 各種サイズ
    class Size {
        static let sendPayMessageFontSize: CGFloat = 60
        static let ptFontSize: CGFloat = 20
        static let sendPayPaddingHorizontal: CGFloat = 50
        static let sendPayPaddingVertical: CGFloat = 20
        static let cornerRadius: CGFloat = 30
    }
    
    struct SelfSendPayMessage: View {
        let message: ChatMessage
        
        var body: some View {
            HStack {
                Spacer()
                VStack {
                    Text("送る")
                        .font(.callout)
                    Spacer()
                    HStack {
                        Text(message.text)
                            .font(.system(size: Size.sendPayMessageFontSize))
                            .bold()
                        Text("pt")
                            .font(.system(size: Size.ptFontSize))
                            .bold()
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, Size.sendPayPaddingHorizontal)
                .padding(.vertical, Size.sendPayPaddingVertical)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: Size.cornerRadius))
            }
        }
    }
    
    struct ChatUserSendPayMessage: View {
        let message: ChatMessage
        let chatUser: ChatUser?
        
        var body: some View {
            HStack {
                VStack {
                    if let image = chatUser?.profileImageUrl {
                        if image == "" {
                            Icon.CustomCircle(imageSize: .small)
                        } else {
                            Icon.CustomWebImage(imageSize: .small, image: image)
                        }
                    } else {
                        Icon.CustomCircle(imageSize: .small)
                    }
                    Spacer()
                }
                VStack {
                    Text("受け取る")
                        .font(.callout)
                    Spacer()
                    HStack {
                        Text(message.text)
                            .font(.system(size: Size.sendPayMessageFontSize))
                            .bold()
                        Text("pt")
                            .font(.system(size: Size.ptFontSize))
                            .bold()
                    }
                    Spacer()
                }
                .foregroundColor(.black)
                .padding(.horizontal, Size.sendPayPaddingHorizontal)
                .padding(.vertical, Size.sendPayPaddingVertical)
                .background(Color(String.chatLogBackground))
                .clipShape(RoundedRectangle(cornerRadius: Size.cornerRadius))
                Spacer()
            }
        }
    }
    
    struct SelfMessage: View {
        let message: ChatMessage
        
        var body: some View {
            HStack {
                Spacer()
                HStack {
                    Text(message.text)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: Size.cornerRadius))
            }
        }
    }
    
    struct ChatUserMessage: View {
        let message: ChatMessage
        let chatUser: ChatUser?
        
        var body: some View {
            HStack {
                VStack {
                    if let image = chatUser?.profileImageUrl {
                        if image == "" {
                            Icon.CustomCircle(imageSize: .small)
                        } else {
                            Icon.CustomWebImage(imageSize: .small, image: image)
                        }
                    } else {
                        Icon.CustomCircle(imageSize: .small)
                    }
                    Spacer()
                }
                HStack {
                    Text(message.text)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color(String.chatLogBackground))
                .clipShape(RoundedRectangle(cornerRadius: Size.cornerRadius))
                Spacer()
            }
        }
    }
}

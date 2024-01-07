//
//  Icon.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/18.
//

import SwiftUI
import SDWebImageSwiftUI

struct Icon {
    
    enum ImageSize {
        case mini
        case small
        case medium
        case large
        
        var frameSize: CGFloat {
            switch self {
            case .mini: 10
            case .small: 40
            case .medium: 60
            case .large: 100
            }
        }
        
        var lineWidth: CGFloat {
            switch self {
            case .mini: 1
            case .small: 1
            case .medium: 2
            case .large: 3
            }
        }
        
        var shadow: CGFloat {
            switch self {
            case .mini: 0
            case .small: 0
            case .medium: 0
            case .large: 5
            }
        }
    }
    
    struct CustomWebImage: View {
        
        let imageSize: ImageSize
        let image: String
        
        var body: some View {
            WebImage(url: URL(string: image))
                .resizable()
                .scaledToFill()
                .frame(width: imageSize.frameSize, height: imageSize.frameSize)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(.black, lineWidth: imageSize.lineWidth)
                        .frame(width: imageSize.frameSize, height: imageSize.frameSize)
                }
                .shadow(radius: imageSize.shadow)
        }
    }
    
    struct CustomCircle: View {
        
        let imageSize: ImageSize
        
        var body: some View {
            Circle()
                .stroke(.black , lineWidth: imageSize.lineWidth)
                .frame(width: imageSize.frameSize, height: imageSize.frameSize)
                .overlay {
                    Circle()
                        .frame(width: imageSize.frameSize - imageSize.lineWidth, height: imageSize.frameSize - imageSize.lineWidth)
                        .foregroundStyle(Color(String.chatLogBackground))
                }
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: imageSize.frameSize / 2))
                        .foregroundColor(.black)
                }
        }
    }
    
    struct CustomImage: View {
        
        let imageSize: ImageSize
        let image: UIImage
        
        var body: some View {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize.frameSize, height: imageSize.frameSize)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(.black, lineWidth: imageSize.lineWidth)
                        .frame(width: imageSize.frameSize, height: imageSize.frameSize)
                }
                .shadow(radius: imageSize.shadow)
        }
    }
}


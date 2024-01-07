//
//  StoreQRCodeView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/31.
//

import SwiftUI

struct StoreQRCodeView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var qrCodeImage: UIImage?
    @Binding var isUserCurrentryLoggedOut: Bool
    
    var body: some View {
        VStack {
            Rectangle()
                .foregroundStyle(.white)
                .frame(width: 300, height: 400)
                .cornerRadius(20)
                .shadow(radius: 7, x: 0, y: 0)
                .overlay {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 15) {
                            if let image = vm.currentUser?.profileImageUrl {
                                if image == "" {
                                    Icon.CustomCircle(imageSize: .medium)
                                } else {
                                    Icon.CustomWebImage(imageSize: .medium, image: image)
                                }
                            } else {
                                Icon.CustomCircle(imageSize: .medium)
                            }
                            Text(vm.currentUser?.username ?? "")
                                .font(.title3)
                                .bold()
                        }
                        
                        Spacer()
                        
                        if vm.onIndicator {
                            ScaleEffectIndicator(onIndicator: $vm.onIndicator)
                        } else {
                            if let qrCodeImage {
                                Image(uiImage: qrCodeImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            } else {
                                VStack {
                                    Text("データを読み込めませんでした。")
                                        .font(.callout)
                                    Button {
                                        qrCodeImage = vm.generateQRCode(inputText: vm.currentUser?.uid ?? "")
                                    } label: {
                                        Image(systemName: "arrow.clockwise")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20)
                                    }
                                }
                                .frame(width: 200, height: 200)
                            }
                        }
                        
                        Spacer()
                        Text("残ポイント: \(vm.currentUser?.money ?? "") pt")
                            .font(.headline)
                        Spacer()
                    }
                }
        }
        .onAppear {
            vm.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.qrCodeImage = vm.generateQRCode(inputText: vm.currentUser?.uid ?? "")
            }
        }
    }
}

#Preview {
    StoreQRCodeView(isUserCurrentryLoggedOut: .constant(false))
}

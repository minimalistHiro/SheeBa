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
    @State private var rect: CGRect = .zero                 // スキャン範囲
    @State private var uiImage: UIImage? = nil
    @State private var isShowActivityView = false
    
    @Binding var isUserCurrentryLoggedOut: Bool
    
    // ボタンの有効性
    var disabled: Bool {
        qrCodeImage == nil
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                if let image = vm.currentUser?.profileImageUrl {
                    if image == "" {
                        Icon.CustomCircle(imageSize: .large)
                    } else {
                        Icon.CustomWebImage(imageSize: .large, image: image)
                    }
                } else {
                    Icon.CustomCircle(imageSize: .large)
                }
                
                Text(vm.currentUser?.username ?? "")
                    .font(.title3)
                    .bold()
                    .padding()
            }
            
            Spacer()
            
            Rectangle()
                .foregroundStyle(.white)
                .frame(width: 180, height: 180)
                .cornerRadius(20)
                .shadow(radius: 7, x: 0, y: 0)
                .background(RectangleGetter(rect: $rect))
                .overlay {
                    VStack {
                        if vm.onIndicator {
                            ScaleEffectIndicator(onIndicator: $vm.onIndicator)
                        } else {
                            if let qrCodeImage {
                                Image(uiImage: qrCodeImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
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
                                .frame(width: 150, height: 150)
                            }
                        }
                    }
                }
            Spacer()
            
            Button {
                let scenes = UIApplication.shared.connectedScenes
                let windowScenes = scenes.first as? UIWindowScene
                if let uiImage = windowScenes?.windows[0].rootViewController?.view!.getImage(rect: self.rect) {
                    self.uiImage = uiImage
                    isShowActivityView = true
                }
            } label: {
                CustomCapsule(text: "QRコードを共有", imageSystemName: "square.and.arrow.up", foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
            }
            .disabled(disabled)
            
            Spacer()
        }
        .onAppear {
            vm.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.qrCodeImage = vm.generateQRCode(inputText: vm.currentUser?.uid ?? "")
            }
        }
        .sheet(isPresented: $isShowActivityView) {
            ActivityView(activityItems: [uiImage as Any], applicationActivities: nil)
        }
    }
}

// MARK: - 範囲キャプチャ用透明View
struct RectangleGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            self.createView(proxy: geometry)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        return Rectangle().fill(Color.clear)
    }
}

#Preview {
    StoreQRCodeView(isUserCurrentryLoggedOut: .constant(false))
}

//
//  QRCodeView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/11/25.
//

import SwiftUI
import CodeScanner

struct QRCodeView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    private let brightness: CGFloat = UIScreen.main.brightness      // 画面遷移前の画面輝度を保持
    @State private var isShowSendPayView = false                    // SendPayViewの表示有無
    @State private var isShowGetPointView = false                   // GetPointViewの表示有無
    @State private var isSameStoreScanError = false                 // 同日同店舗スキャンエラー
    @State private var chatUserUID = ""                 // 送金相手UID
    
    enum QRCodeMode {
        case qrCode
        case camera
    }
    
    @State private var qrCodeMode: QRCodeMode = .qrCode
    @State private var qrCodeImage: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if qrCodeMode == .qrCode {
                    qrCodeView
                } else {
                    cameraView
                }
                buttons
            }
            .asCloseButton()
            .navigationDestination(isPresented: $isShowGetPointView) {
                GetPointView(chatUser: vm.chatUser)
            }
        }
        .onAppear {
            UIScreen.main.brightness = 1.0
            vm.fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.qrCodeImage = vm.generateQRCode(inputText: vm.currentUser?.uid ?? "")
            }
        }
        .onChange(of: vm.isQrCodeScanError) { _ in
            // 1.5秒後にQRコード読みよりエラーをfalseにする。
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                vm.isQrCodeScanError = false
                isSameStoreScanError = false
            }
        }
        .onDisappear {
            UIScreen.main.brightness = brightness
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
    }
    
    // MARK: - qrCodeView
    private var qrCodeView: some View {
        VStack {
            Spacer()
            
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
            
            Spacer()
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - cameraView
    private var cameraView: some View {
        CodeScannerView(codeTypes: [.qr], completion: handleScan)
            .overlay {
                if vm.isQrCodeScanError {
                    ZStack {
                        Color(.red)
                            .opacity(0.5)
                        VStack {
                            Image(systemName: "multiply")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundStyle(.white)
                                .opacity(0.6)
                                .padding(.bottom)
                            RoundedRectangle(cornerRadius: 20)
                                .padding(.horizontal)
                                .frame(width: UIScreen.main.bounds.width, height: 40)
                                .foregroundStyle(.black)
                                .opacity(0.7)
                                .overlay {
                                    Text(isSameStoreScanError ? "このQRコードは後日0時に有効になります。" : "誤ったQRコードがスキャンされました")
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                } else {
                    Rectangle()
                        .stroke(style:
                                    StrokeStyle(
                                        lineWidth: 7,
                                        lineCap: .round,
                                        lineJoin: .round,
                                        miterLimit: 50,
                                        dash: [100, 100],
                                        dashPhase: 50
                                    ))
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.white)
                }
            }
            .fullScreenCover(isPresented: $isShowSendPayView) {
                SendPayView(didCompleteSendPayProcess: { sendPayText in
                    isShowSendPayView.toggle()
                    vm.handleSend(toId: chatUserUID, chatText: "", lastText: sendPayText, isSendPay: true)
                    dismiss()
                }, chatUser: vm.chatUser)
            }
    }
    
    // MARK: - buttons
    private var buttons: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    qrCodeMode = .qrCode
                } label: {
                    VStack {
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .padding(.bottom)
                        Text("QRコードを表示する")
                            .font(.caption)
                    }
                }
                .foregroundStyle(qrCodeMode == .qrCode ? .black : .gray)
                
                Spacer()
                
                Button{
                    qrCodeMode = .camera
                } label: {
                    VStack {
                        Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .padding(.bottom)
                        Text("QRコードを読み取る")
                            .font(.caption)
                    }
                }
                .foregroundStyle(qrCodeMode == .camera ? .black : .gray)
                
                Spacer()
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - QRコード読み取り処理
    /// - Parameters:
    ///   - result: QRコード読み取り結果
    /// - Returns: なし
    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            let fetchedUid = result.string
            self.chatUserUID = fetchedUid
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                vm.handleError(String.failureFetchUID, error: nil)
                return
            }
            
            // 同アカウントのQRコードを読み取ってしまった場合、エラーを発動。
            if uid == self.chatUserUID {
                vm.isQrCodeScanError = true
                return
            }
            
            vm.fetchUser(uid: chatUserUID)
            
            // 遅らせてSendPayViewを表示する
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let chatUser = vm.chatUser else {
                    vm.handleError(String.failureFetchUser, error: nil)
                    return
                }
                vm.fetchStorePoint(document1: uid, document2: chatUser.uid)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // 店舗QRコードの場合
                    if chatUser.isStore {
                        // 店舗ポイント情報がある場合は場合分け、ない場合はポイントを獲得する。
                        if let storePoint = vm.storePoint {
                            // 店舗QRコードが同日に2度以上のスキャンでない場合
                            if storePoint.date != vm.dateFormat(Date()) {
                                handleGetPointFromStore(chatUser: chatUser)
                                UIScreen.main.brightness = brightness
                                self.isShowGetPointView = true
                            } else {
                                vm.isQrCodeScanError = true
                                isSameStoreScanError = true
                            }
                        } else {
                            handleGetPointFromStore(chatUser: chatUser)
                            UIScreen.main.brightness = brightness
                            self.isShowGetPointView = true
                        }
                    } else {
                        if !vm.isQrCodeScanError {
                            UIScreen.main.brightness = brightness
                            self.isShowSendPayView = true
                        }
                    }
                }
            }
        case .failure(let error):
            vm.isQrCodeScanError = true
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 店舗からポイント取得処理
    /// - Parameters: なし
    /// - Returns: なし
    private func handleGetPointFromStore(chatUser: ChatUser) {
        guard let currentUser = vm.currentUser else { return }
        
        guard let currentUserMoney = Int(currentUser.money) else {
            vm.handleError("送金エラーが発生しました。", error: nil)
            return
        }
        
        // 残高に取得ポイントを足す
        let calculatedCurrentUserMoney = currentUserMoney + 1
        
        // 自身のユーザー情報を更新
        let userData = [FirebaseConstants.money: String(calculatedCurrentUserMoney),]
        vm.updateUsers(document: currentUser.uid, data: userData)
        
        // 店舗ポイント情報を更新
        let storePointData = [
            FirebaseConstants.uid: chatUser.uid,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.getPoint: "1",
            FirebaseConstants.username: chatUser.username,
            FirebaseConstants.date: Date(),
        ] as [String : Any]
        vm.persistStorePoints(document1: currentUser.uid, document2: chatUser.uid, data: storePointData)
    }
}

#Preview {
    QRCodeView()
}

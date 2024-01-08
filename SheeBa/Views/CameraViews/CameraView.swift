//
//  CameraView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2024/01/01.
//

import SwiftUI
import CodeScanner

struct CameraView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var isShowSendPayView = false        // SendPayViewの表示有無
    @State private var isShowGetPointView = false       // GetPointViewの表示有無
    @State private var isSameStoreScanError = false     // 同日同店舗スキャンエラー
    @State private var isShowSignOutAlert = false                       // 強制サインアウトアラート
    
    @State private var chatUserUID = ""                 // 送金相手UID
    @State private var getPoint = ""                    // 取得ポイント
    
    @Binding var isUserCurrentryLoggedOut: Bool
    
    var body: some View {
        NavigationStack {
            if let isStore = vm.currentUser?.isStore, isStore {
                Text("店舗アカウントのため、\nカメラの読み取りは不可能です。")
            } else {
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
                    .navigationDestination(isPresented: $isShowGetPointView) {
                        GetPointView(chatUser: vm.chatUser, getPoint: getPoint, isSameStoreScanError: isSameStoreScanError)
                    }
            }
        }
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                if let isStore = vm.currentUser?.isStore, isStore {
                    // 何も取得しない
                } else {
                    vm.fetchCurrentUser()
                    vm.fetchRecentMessages()
                    vm.fetchFriends()
                    vm.fetchStorePoints()
                }
            } else {
                isUserCurrentryLoggedOut = true
            }
        }
        .onChange(of: vm.isQrCodeScanError) { _ in
            // 1.5秒後にQRコード読みよりエラーをfalseにする。
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                vm.isQrCodeScanError = false
                isSameStoreScanError = false
            }
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: {
            DispatchQueue.main.async {
                vm.isShowError = false
            }
            isShowSignOutAlert = true
        })
        .asSingleAlert(title: "",
                        isShowAlert: $isShowSignOutAlert,
                        message: "エラーが発生したためログアウトします。",
                        didAction: {
             DispatchQueue.main.async {
                 isShowSignOutAlert = false
             }
             handleSignOut()
         })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowNotConfirmEmailError,
                       message: "メールアドレスの認証を完了してください",
                       didAction: {
            vm.isNavigateNotConfirmEmailView = true
        })
        .fullScreenCover(isPresented: $isUserCurrentryLoggedOut) {
            EntryView {
                isUserCurrentryLoggedOut = false
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
                vm.fetchFriends()
                vm.fetchStorePoints()
            }
        }
        .fullScreenCover(isPresented: $isShowSendPayView) {
            SendPayView(didCompleteSendPayProcess: { sendPayText in
                isShowSendPayView.toggle()
                vm.handleSend(toId: chatUserUID, chatText: "", lastText: sendPayText, isSendPay: true)
                dismiss()
            }, chatUser: vm.chatUser)
        }
        .fullScreenCover(isPresented: $vm.isNavigateNotConfirmEmailView) {
            NotConfirmEmailView {
                vm.isNavigateNotConfirmEmailView = false
            }
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
            vm.fetchStorePoint(document1: uid, document2: self.chatUserUID)
            
            // 遅らせてSendPayViewを表示する
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard let chatUser = vm.chatUser else {
                    vm.handleError(String.failureFetchUser, error: nil)
                    return
                }
                
                // 店舗QRコードの場合
                if chatUser.isStore {
                    // 店舗ポイント情報がある場合は場合分け、ない場合はポイントを獲得する。
                    if let storePoint = vm.storePoint {
                        // 店舗QRコードが同日に2度以上のスキャンでない場合
                        if storePoint.date != vm.dateFormat(Date()) {
                            handleGetPointFromStore(chatUser: chatUser)
                            self.isShowGetPointView = true
                        } else {
//                            vm.isQrCodeScanError = true
                            isSameStoreScanError = true
                            self.isShowGetPointView = true
                            return
                        }
                    } else {
                        handleGetPointFromStore(chatUser: chatUser)
                        self.isShowGetPointView = true
                    }
                } else {
                    if !vm.isQrCodeScanError {
                        self.isShowSendPayView = true
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
        getPoint = Setting.getPointFromStore
        
        guard let currentUserMoney = Int(currentUser.money),
              let intGetPoint = Int(getPoint) else {
            vm.handleError("送金エラーが発生しました。", error: nil)
            return
        }
        
        // 残高に取得ポイントを足す
        let calculatedCurrentUserMoney = currentUserMoney + intGetPoint
        
        // 自身のユーザー情報を更新
        let userData = [FirebaseConstants.money: String(calculatedCurrentUserMoney),]
        vm.updateUser(document: currentUser.uid, data: userData)
        
        // 店舗ポイント情報を更新
        let storePointData = [
            FirebaseConstants.uid: chatUser.uid,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.getPoint: getPoint,
            FirebaseConstants.username: chatUser.username,
            FirebaseConstants.date: vm.dateFormat(Date()),
        ] as [String : Any]
        vm.persistStorePoint(document1: currentUser.uid, document2: chatUser.uid, data: storePointData)
    }
    
    // MARK: - サインアウト
    /// - Parameters: なし
    /// - Returns: なし
    private func handleSignOut() {
        isUserCurrentryLoggedOut = true
        try? FirebaseManager.shared.auth.signOut()
    }
}

#Preview {
    CameraView(isUserCurrentryLoggedOut: .constant(false))
}

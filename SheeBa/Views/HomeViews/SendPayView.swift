//
//  SendPayView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/29.
//

import SwiftUI

struct SendPayView: View {
    
    @ObservedObject var vm = ViewModel()
    let didCompleteSendPayProcess: (String) -> ()
    @State private var isShowSendPayAlert = false       // 送金アラート
    @State private var sendPayText = "0"                // 送金テキスト
    @State private var inputs: Inputs = .tappedAC       // ボタン押下実行処理
    let keyboard = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "0", "00", "AC"]
    let chatUser: ChatUser?
    
    init(didCompleteSendPayProcess: @escaping (String) -> (), chatUser: ChatUser?) {
//        print("~SendPayView~\n")
        self.didCompleteSendPayProcess = didCompleteSendPayProcess
        self.chatUser = chatUser
        vm.fetchCurrentUser()
    }
    
    // 入力ステータス
    enum Inputs {
        case tappedAC                   // キーボード（"AC"）
        case tappedNumberPad            // キーボード（数字）
    }

    var body: some View {
        NavigationStack {
            VStack {
                // トップ画像
                if let image = chatUser?.profileImageUrl {
                    if image == "" {
                        Icon.CustomCircle(imageSize: .large)
                    } else {
                        Icon.CustomWebImage(imageSize: .large, image: image)
                    }
                } else {
                    Icon.CustomCircle(imageSize: .large)
                }
                HStack {
                    Text("\(chatUser?.username ?? "No name")")
                        .font(.headline)
                    Text("さんに送る")
                }
                
                HStack {
                    Text("\(sendPayText)")
                        .font(.system(size: 50))
                        .bold()
                    Text("pt")
                        .font(.title)
                }
                
                Spacer()
                
                // 送るボタン
                Button{
                    // 送金する金額が0円以下の場合、アラートを発動
                    if (Int(sendPayText) ?? 0) <= 0 {
                        vm.handleError("0より大きい数字を入力してください。", error: nil)
                        return
                    }
                    isShowSendPayAlert = true
                } label: {
                    RoundedRectangle(cornerSize: CGSize(width: 15 , height: 15))
                        .frame(width: 100, height: 50)
                        .foregroundStyle(.blue)
                        .overlay {
                            Text("送る")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                }
                
                // キーボード
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 30) {
                    ForEach(keyboard, id: \.self) { index in
                        Button {
                            apply(index)
                        } label: {
                            Text("\(index)")
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(index == "AC" ? Color.red : Color.black)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 30)
                .asCloseButton()
            }
        }
        .onAppear {
            vm.fetchFriends()
        }
        // 送金アラート
        .asDoubleAlert(title: "",
                       isShowAlert: $isShowSendPayAlert,
                       message: "\(sendPayText)pt送りますか？",
                       buttonText: "送る",
                       didAction: {
            handleSendPay()
            isShowSendPayAlert = false
            if !vm.isShowError {
                didCompleteSendPayProcess(sendPayText)
            }
        })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
    }
    
    // MARK: - 送金処理
    /// - Parameters: なし
    /// - Returns: なし
    private func handleSendPay() {
        guard let chatUser = chatUser else { return }
        guard let currentUser = vm.currentUser else { return }
        
        // 互いに友達登録していない場合、新規友達登録をする。
        persistOrUpdateFriend(currentUser: currentUser, chatUser: chatUser)
        
        guard let chatUserMoney = Int(chatUser.money),
              let currentUserMoney = Int(currentUser.money),
              let sendPayText = Int(sendPayText) else {
            vm.handleError("送金エラーが発生しました。", error: nil)
            return
        }
        
        // 各ユーザーの残高を計算
        let calculatedChatUserMoney = chatUserMoney + sendPayText
        let calculatedCurrentUserMoney = currentUserMoney - sendPayText
        
        // 各ユーザーの残高が0以下の場合、アラートを発動
        if (calculatedChatUserMoney < 0) || (calculatedCurrentUserMoney < 0) {
            vm.handleError("入力数値が残ポイントを超えています。", error: nil)
            return
        }
        
        // 送金相手のデータを更新
        let chatUserData = [FirebaseConstants.money: String(calculatedChatUserMoney),]
        vm.updateUser(document: chatUser.uid, data: chatUserData)
        
        // 自身のデータを更新
        let userData = [FirebaseConstants.money: String(calculatedCurrentUserMoney),]
        vm.updateUser(document: currentUser.uid, data: userData)
    }
    
    // MARK: - 友達を登録、若しくは更新をする。
    /// - Parameters:
    ///   - currentUser: 自身
    ///   - chatUser: 送ポイント相手
    /// - Returns: なし
    private func persistOrUpdateFriend(currentUser: ChatUser, chatUser: ChatUser) {
        for friend in vm.friends {
            if friend.uid == chatUser.uid {
                if friend.isApproval {
                    // 友達に登録されていて承認済みである場合何もしない。
                    return
                } else {
                    // 友達に登録されていて承認が済んでいない場合、自身と相手の両方のデータを更新
                    let data = [FirebaseConstants.isApproval: true,]
                    vm.updateFriend(document1: currentUser.uid
                                     , document2: chatUser.uid, data: data)
                    vm.updateFriend(document1: chatUser.uid, document2: currentUser.uid, data: data)
                    return
                }
            }
        }
        // 友達に登録されていない場合、友達登録をする。
        persistFriend(currentUser: currentUser, chatUser: chatUser)
    }
    
    // MARK: - 友達を保存
    /// - Parameters:
    ///   - currentUser: 自身
    ///   - chatUser: 追加するユーザー
    /// - Returns: なし
    private func persistFriend(currentUser: ChatUser, chatUser: ChatUser) {
        // 自身の友達データを保存
        let myData = [
            FirebaseConstants.uid: chatUser.uid,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.money: chatUser.money,
            FirebaseConstants.username: chatUser.username,
            FirebaseConstants.isApproval: true,
            FirebaseConstants.approveUid: currentUser.uid,
            FirebaseConstants.isStore: currentUser.isStore,
        ] as [String : Any]
        
        vm.persistFriend(document1: currentUser.uid, document2: chatUser.uid, data: myData)
        
        // 送ポイント相手の友達データを保存
        let chatUserData = [
            FirebaseConstants.uid: currentUser.uid,
            FirebaseConstants.email: currentUser.email,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.money: currentUser.money,
            FirebaseConstants.username: currentUser.username,
            FirebaseConstants.isApproval: true,
            FirebaseConstants.approveUid: currentUser.uid,
            FirebaseConstants.isStore: currentUser.isStore,
        ] as [String : Any]
        
        vm.persistFriend(document1: chatUser.uid, document2: currentUser.uid, data: chatUserData)
    }
    
    // MARK: - キーボード入力から実行処理を分配する
    /// - Parameters:
    ///   - keyboard: 入力されたキーボード
    /// - Returns: なし
    private func apply(_ keyboard: String) {
        // 入力したキーボードから入力ステータス（Inputs）を振り分ける。
        if let _ = Double(keyboard) {
            tappedNumberPadProcess(keyboard)
        } else if keyboard == "AC" {
            sendPayText = "0"
            inputs = .tappedAC
        }
    }
    
    // MARK: - 数字キーボード実行処理
    /// - Parameters:
    ///   - keyboard: 入力されたキーボード
    /// - Returns: なし
    private func tappedNumberPadProcess(_ keyboard: String) {
        // テキストが初期値"0"の時に、"0"若しくは"00"が入力された時、何もしない。
        if sendPayText == "0" && (keyboard == "0" || keyboard == "00") {
            return
        }
        
        if inputs == .tappedNumberPad {
            // テキストに表示できる最大数字を超えないように制御
            if isCheckOverMaxNumberOfDigits(sendPayText + keyboard) {
                return
            }
            if sendPayText == "0" {
                sendPayText = keyboard
            } else {
                sendPayText += keyboard
            }
        } else {
            // 初回に"00"が入力された時、"0"と表記する。
            if keyboard == "00" {
                sendPayText = "0"
            } else {
                sendPayText = keyboard
            }
        }
        inputs = .tappedNumberPad
    }
    
    // MARK: - 計算結果がテキスト最大文字数を超えているかをチェックする。
    /// - Parameters:
    ///   - numberText: テキストに表示できる最大桁数に合わせて小数点以下を丸めたテキスト
    /// - Returns: テキスト最大文字数以内の場合True、そうでない場合false。
    private func isCheckOverMaxNumberOfDigits(_ numberText: String) -> Bool {
        if numberText.count > Setting.maxNumberOfDigits {
            return true
        }
        return false
    }
}

#Preview {
    SendPayView(didCompleteSendPayProcess: {_ in}, chatUser: nil)
}

//
//  UpdateUsername.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/12.
//

import SwiftUI

struct UpdateUsernameView: View {
    
    @FocusState var focus: Bool
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var editText = ""                // 編集テキスト
    @State private var disabled = true              // ボタンの有効性
    @State private var isShowCloseAlert = false     // 変更破棄確認アラート
    @State private var isShowChangeAlert = false    // 変更確認アラート
    @State private var isShowSuccessAlert = false   // 変更成功確認アラート
    let username: String
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                InputText.InputTextField(focus: $focus, editText: $editText, titleText: "ユーザー名", textType: .other)
                
                Spacer()
                
                Button {
                    isShowChangeAlert = true
                } label: {
                    CustomCapsule(text: "変更", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                }
                .disabled(disabled)
                
                Spacer()
                Spacer()
            }
            // タップでキーボードを閉じるようにするため
            .contentShape(Rectangle())
            .onTapGesture {
                focus = false
            }
        }
        .asAlertBackButton {
            // テキストに変更がない、もしくは空の場合、警告を表示せず閉じる。
            if disabled {
                dismiss()
            } else {
                isShowCloseAlert = true
            }
        }
        .navigationTitle("ユーザー名を変更")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.fetchCurrentUser()
            vm.fetchRecentMessages()
            vm.fetchFriends()
            editText = username
        }
        .onChange(of: editText) { text in
            // テキストに変更がない、もしくは空の場合、ボタンを無効にする。
            if text == username || text.isEmpty {
                disabled = true
            } else {
                disabled = false
            }
        }
        .asDoubleAlert(title: "",
                       isShowAlert: $isShowChangeAlert,
                       message: "ユーザー名を変更しますか？",
                       buttonText: "変更",
                       didAction: {
            vm.onIndicator = true
            updateUsername(username: editText)
            vm.onIndicator = false
            isShowChangeAlert = false
            isShowSuccessAlert = true
        })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowSuccessAlert,
                       message: "変更しました。",
                       didAction: {
            isShowSuccessAlert = false
            dismiss()
        })
        .asDestructiveAlert(title: "",
                            isShowAlert: $isShowCloseAlert,
                            message: "変更を中止しますか？",
                            buttonText: "中止") {
            dismiss()
        }
    }
    
    /// ユーザー名を更新
    /// - Parameters:
    ///   - username: 更新するユーザー名
    /// - Returns: なし
    private func updateUsername(username: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let data = [FirebaseConstants.username: username,]
        
        // ユーザー情報を更新
        vm.updateUsers(document: uid, data: data)
        
        // 最新メッセージを更新
        for recentMessage in vm.recentMessages {
            vm.updateRecentMessages(document1: uid == recentMessage.fromId ? recentMessage.toId :  recentMessage.fromId, document2: uid, data: data)
        }
        
        // 友達情報を更新
        for friend in vm.friends {
            vm.updateFriends(document1: friend.uid, document2: uid, data: data)
        }
    }
}

#Preview {
    UpdateUsernameView(username: "test")
}

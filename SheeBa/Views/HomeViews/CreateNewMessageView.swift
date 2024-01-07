//
//  CreateNewMessageView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/16.
//

import SwiftUI

struct CreateNewMessageView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var isShowAddFriendAlert = false         // 友達追加アラート
//    @State private var allUsers = [ChatUser]()              // 全ユーザー
    @State private var resultUsers = [ChatUser]()           // 検索に一致したユーザー名
    @State private var searchText = ""                      // 検索テキスト
    @State private var chatUser: ChatUser?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(resultUsers) { user in
                    Button {
                        isShowAddFriendAlert = true
                        self.chatUser = user
                    } label: {
                        HStack(spacing: 16) {
                            if user.profileImageUrl == "" {
                                Icon.CustomCircle(imageSize: .medium)
                            } else {
                                Icon.CustomWebImage(imageSize: .medium, image: user.profileImageUrl)
                            }
                            Text(user.username)
                                .foregroundStyle(Color(.label))
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .asCloseButton()
        }
        .onAppear {
            vm.fetchCurrentUser()
            vm.fetchRecentMessages()
            vm.fetchFriends()
            vm.fetchAllUsers()
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            fetchSearchNames()
        }
        .asDoubleAlert(title: "",
                       isShowAlert: $isShowAddFriendAlert,
                       message: "友達追加リクエストを送信しますか？",
                       buttonText: "リクエスト送信",
                       didAction: {
            persistFriend(chatUser: chatUser)
            dismiss()
        })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
    }
    
    /// 検索に一致した名前を取得
    /// - Parameters: なし
    /// - Returns: なし
    private func fetchSearchNames() {
        resultUsers = []
        
        if searchText.isEmpty {
            resultUsers = []
        } else if vm.recentMessages == [] {
            // 最新メッセージが空の場合
            resultUsers = vm.allUsers.filter { user in
                // 全ユーザーの中に、既に友達申請しているユーザーは排除する。
                for friend in vm.friends {
                    if friend.uid == user.uid {
                        return false
                    }
                }
                // 検索ワードに一致しているーザーネームのみ含める。
                if user.username.contains(searchText) {
                    return true
                }
                return false
            }
        } else {
            let filteredUsers = vm.allUsers.filter {
                // 検索ワードに一致しているーザーネームのみ含める。
                $0.username.contains(searchText)
            }
            
            // 最新メッセージのトーク相手のuidを取得
            let recentMessageId = vm.recentMessages.map {
                FirebaseManager.shared.auth.currentUser?.uid == $0.fromId ? $0.toId : $0.fromId
            }
            
            // 最新メッセージを取得した相手を省く。
            resultUsers = filteredUsers.filter {
                !recentMessageId.contains($0.uid)
            }
        }
    }
    
    // MARK: - 友達を保存
    /// - Parameters:
    ///   - chatUser: 追加するユーザー
    /// - Returns: なし
    private func persistFriend(chatUser: ChatUser?) {
        guard let currentUser = vm.currentUser else { return }
        guard let chatUser = chatUser else { return }
        
        // 自身の友達データを保存
        let myData = [
            FirebaseConstants.uid: chatUser.uid,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.money: chatUser.money,
            FirebaseConstants.username: chatUser.username,
            FirebaseConstants.isApproval: false,
            FirebaseConstants.approveUid: currentUser.uid,
            FirebaseConstants.isStore: currentUser.isStore,
        ] as [String : Any]
        
        vm.persistFriends(document1: currentUser.uid, document2: chatUser.uid, data: myData)
        
        // リクエスト相手の友達データを保存
        let chatUserData = [
            FirebaseConstants.uid: currentUser.uid,
            FirebaseConstants.email: currentUser.email,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.money: currentUser.money,
            FirebaseConstants.username: currentUser.username,
            FirebaseConstants.isApproval: false,
            FirebaseConstants.approveUid: currentUser.uid,
            FirebaseConstants.isStore: currentUser.isStore,
        ] as [String : Any]
        
        vm.persistFriends(document1: chatUser.uid, document2: currentUser.uid, data: chatUserData)
    }
}

#Preview {
    CreateNewMessageView()
}

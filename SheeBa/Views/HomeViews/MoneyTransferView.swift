//
//  MoneyTransferView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import SwiftUI
import SDWebImageSwiftUI

struct MoneyTransferView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var shouldShowLoginOutOptions = false
    @State private var shouldShowNewMessageScreen = false
    @State private var shouldNavigateToChatLogView = false
    @State private var isShowApproveOrNotAlert = false      // 承認するか否かのアラート
    @State private var approveUserUID: String?
    @State private var tab: Tab = .history
    
    enum Tab {
        case history
        case friend
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                CustomTabBar(tab: $tab, buttonTab: .history)
                CustomTabBar(tab: $tab, buttonTab: .friend)
            }
            .foregroundStyle(.black)
            
            VStack {
                switch tab {
                case .history:
                    recentMessageList
                case .friend:
                    friendList
                }
            }
            .overlay {
                searchNewMemverButton
            }
        }
        .asBackButton()
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
            }
        }
        .onChange(of: tab) { value in
            switch value {
            case .history:
                vm.fetchRecentMessages()
            case .friend:
                vm.fetchFriends()
            }
        }
    }
    
    // MARK: - recentMessageList
    private var recentMessageList: some View {
        List {
            ForEach(vm.recentMessages) { recentMessage in
                VStack(spacing: 2) {
                    NavigationLink {
                        ChatLogView(chatUserUID: FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId :  recentMessage.fromId)
                    } label: {
                        HistoryButton(recentMessage: recentMessage)
                    }
                }
                .listRowSeparator(.hidden)
//                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                    Button(role: .destructive) {
//                        if let uid = FirebaseManager.shared.auth.currentUser?.uid {
//                            // 最新メッセージ、メッセージを削除
//                            vm.deleteRecentMessage(document1: uid, document2: uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId)
//                            vm.deleteMessages(document: uid, collection: uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId)
//                        }
//                    } label: {
//                        Image(systemName: "trash")
//                    }
//                    .tint(.red)
//                }
            }
            Spacer()
                .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
    }
    
    // MARK: - friendList
    private var friendList: some View {
        List {
            ForEach(vm.friends) { friend in
                VStack(spacing: 2) {
                    if friend.isApproval {
                        NavigationLink {
                            ChatLogView(chatUserUID: friend.uid)
                        } label: {
                            FriendButton(friend: friend)
                        }
                    } else {
                        if friend.approveUid == FirebaseManager.shared.auth.currentUser?.uid {
                            Button {
                                vm.handleError("相手からのリクエスト許可を待っています。", error: nil)
                            } label: {
                                FriendButton(friend: friend)
                            }
                        } else {
                            Button {
                                self.approveUserUID = friend.uid
                                isShowApproveOrNotAlert = true
                            } label: {
                                FriendButton(friend: friend)
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        if let uid = FirebaseManager.shared.auth.currentUser?.uid {
                            // 友達情報を削除
                            vm.deleteFriend(document1: uid, document2: friend.uid)
                            
                            // 最新メッセージ、メッセージを削除
                            vm.deleteRecentMessage(document1: uid, document2: friend.uid)
                            vm.deleteMessages(document: uid, collection: friend.uid)
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
            
            Spacer()
                .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
        .asTripleAlert(title: "このユーザーからのリクエストを承認しますか？",
                       isShowAlert: $isShowApproveOrNotAlert,
                       message: "リクエストを承認すると、メッセージ交換、送金が可能になります。",
                       buttonText: "承認",
                       destructiveButtonText: "辞退",
                       didAction: {
            if let toId = approveUserUID {
                handleApprove(toId: toId)
            }
        },
                       didDestructiveAction: {
            // 友達情報を削除
            if let uid = FirebaseManager.shared.auth.currentUser?.uid, let toId = approveUserUID {
                // 自分と相手の友達情報を削除
                vm.deleteFriend(document1: uid, document2: toId)
                vm.deleteFriend(document1: toId, document2: uid)
            }
        })
    }
    
    // MARK: - CustomTabBar
    struct CustomTabBar: View {
        @Binding var tab: MoneyTransferView.Tab
        let buttonTab: MoneyTransferView.Tab
        
        var imageSystemName: String {
            switch buttonTab {
            case .history:
                "clock.arrow.circlepath"
            case .friend:
                "person.2"
            }
        }
        
        // 各種サイズ
        let frameWidthHeight: CGFloat = 30
        let rectangleFrameHeight: CGFloat = 2
        
        var body: some View {
            VStack {
                Button {
                    tab = buttonTab
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: imageSystemName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: frameWidthHeight, height: frameWidthHeight)
                        Spacer()
                    }
                }
                Rectangle()
                    .foregroundColor(tab == buttonTab ? .black : .white)
                    .frame(height: rectangleFrameHeight)
            }
        }
    }
    
    // MARK: - HistoryButton
    struct HistoryButton: View {
        let recentMessage: RecentMessage
        
        var body: some View {
            HStack(spacing: 16) {
                if recentMessage.profileImageUrl == "" {
                    Icon.CustomCircle(imageSize: .medium)
                } else {
                    Icon.CustomWebImage(imageSize: .medium, image: recentMessage.profileImageUrl)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text(recentMessage.username)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.black)
                    if recentMessage.isSendPay {
                        if let uid = FirebaseManager.shared.auth.currentUser?.uid {
                            Text(recentMessage.text + (uid == recentMessage.fromId ? "pt送りました": "pt受け取りました"))
                                .font(.caption)
                                .foregroundStyle(Color.black)
                        }
                    } else {
                        Text(recentMessage.text)
                            .font(.caption)
                            .foregroundStyle(Color.black)
                    }
                }
                
                Spacer()
                
                Text(recentMessage.timeAgo)
                    .font(.caption2)
                    .foregroundStyle(Color.black)
            }
        }
    }
    
    // MARK: - FriendButton
    struct FriendButton: View {
        let friend: Friend
        
        var body: some View {
            HStack(spacing: 16) {
                if friend.profileImageUrl == "" {
                    Icon.CustomCircle(imageSize: .medium)
                } else {
                    Icon.CustomWebImage(imageSize: .medium, image: friend.profileImageUrl)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text(friend.username)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.black)
                }
                
                Spacer()
                
                if !friend.isApproval {
                    Image(systemName: "exclamationmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    // MARK: - searchNewMemverButton
    private var searchNewMemverButton: some View {
        VStack {
            Spacer()
            Button {
                shouldShowNewMessageScreen.toggle()
            } label: {
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 60)
                    .overlay {
                        Image(systemName: "person.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 30)
                    }
            }
            .padding(.bottom)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
//            CreateNewMessageView { user in
//                self.shouldNavigateToChatLogView.toggle()
//                self.vm.chatUser = user
//                self.vm.fetchMessages(toId: user.uid)
//            }
            CreateNewMessageView()
        }
    }
    
    // MARK: - 承認処理
    /// - Parameters:
    ///   - toId: リクエスト承認相手のUID
    /// - Returns: なし
    private func handleApprove(toId: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let data = [FirebaseConstants.isApproval: true,]
        // 自身と相手の両方のデータを更新
        vm.updateFriends(document1: uid, document2: toId, data: data)
        vm.updateFriends(document1: toId, document2: uid, data: data)
        
        vm.fetchFriends()
    }
    
    // MARK: - 最新メッセージ、メッセージを削除
    /// - Parameters:
    ///   - toId: トーク相手UID
    /// - Returns: なし
//    private func deleteRecentMessageAndMessages(toId: String) {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
//
//        // 最新メッセージを削除
//        vm.deleteRecentMessage(document1: uid, document2: toId)
//
//        // メッセージを削除
//        vm.deleteMessages(document: uid, collection: toId)
//    }
}

#Preview {
    MoneyTransferView()
}

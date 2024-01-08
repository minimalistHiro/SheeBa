//
//  UpdateImageView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/08.
//

import SwiftUI

struct UpdateImageView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var isShowImagePicker = false            // ImagePicker表示有無
    @State private var isShowChangeSuccessAlert = false     // 変更成功アラート
    @State private var uiImage: UIImage?                      // トップ画像
    
    // ボタンの有効性
    var disabled: Bool {
        uiImage == nil
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Button {
                    isShowImagePicker.toggle()
                } label: {
                    if let uiImage = uiImage {
                        Icon.CustomImage(imageSize: .xLarge, image: uiImage)
                            .overlay {
                                Icon.CustomImageChangeCircle(imageSize: .xLarge)
                            }
                    } else {
                        if let imageUrl = vm.currentUser?.profileImageUrl, imageUrl != "" {
                            Icon.CustomWebImage(imageSize: .xLarge, image: imageUrl)
                                .overlay {
                                    Icon.CustomImageChangeCircle(imageSize: .xLarge)
                                }
                        } else {
                            Icon.CustomCircle(imageSize: .xLarge)
                                .overlay {
                                    Icon.CustomImageChangeCircle(imageSize: .xLarge)
                                }
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    persistAndDeleteImage(image: uiImage)
                } label: {
                    CustomCapsule(text: "確定", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                }
                .disabled(disabled)
                
                Spacer()
                Spacer()
            }
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
        }
        .asBackButton()
        .navigationTitle("トップ画像を変更")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
                vm.fetchFriends()
            }
        }
        .asSingleAlert(title: "",
                       isShowAlert: $isShowChangeSuccessAlert,
                       message: "変更しました。",
                       didAction: {
            isShowChangeSuccessAlert = false
            dismiss()
        })
        .fullScreenCover(isPresented: $isShowImagePicker) {
            ImagePicker(selectedImage: $uiImage)
        }
    }
    
    /// 画像を保存
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    ///   - image: トップ画像
    /// - Returns: なし
    private func persistAndDeleteImage(image: UIImage?) {
        vm.onIndicator = true
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        // 画像削除
        vm.deleteImage(withPath: uid)
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { _, error in
            if error != nil {
                vm.handleError("画像の保存に失敗しました。", error: error)
                return
            }
            // Firestore Databaseに保存するためにURLをダウンロードする。
            ref.downloadURL { url, error in
                if error != nil {
                    vm.handleError("画像URLの取得に失敗しました。", error: error)
                    return
                }
                guard let url = url else { return }
                updateImage(profileImageUrl: url)
            }
        }
    }
    
    /// トップ画像を更新
    /// - Parameters:
    ///   - profileImageUrl: 更新するトップ画像URL
    /// - Returns: なし
    private func updateImage(profileImageUrl: URL?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let data = [FirebaseConstants.profileImageUrl: profileImageUrl?.absoluteString ?? "",]
        
        // ユーザー情報を更新
        vm.updateUser(document: uid, data: data)
        
        // 最新メッセージを更新
        for recentMessage in vm.recentMessages {
            vm.updateRecentMessage(document1: uid == recentMessage.fromId ? recentMessage.toId :  recentMessage.fromId, document2: uid, data: data)
        }
        
        // 友達情報を更新
        for friend in vm.friends {
            vm.updateFriend(document1: friend.uid, document2: uid, data: data)
        }
        
        vm.onIndicator = false
        isShowChangeSuccessAlert = true
    }
}

#Preview {
    UpdateImageView()
}

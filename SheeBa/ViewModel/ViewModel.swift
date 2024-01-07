//
//  ViewModel.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/02.
//

import SwiftUI
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseAnalytics

final class ViewModel: ObservableObject {
    
    @Published var currentUser: ChatUser?                       // 現在のユーザー
    @Published var chatUser: ChatUser?                          // トーク相手ユーザー
    @Published var allUsers = [ChatUser]()                      // 全ユーザー
    @Published var friends = [Friend]()                         // 友達ユーザー
    @Published var friend: Friend?                              // 特定の友達情報
    @Published var recentMessages = [RecentMessage]()           // 全最新メッセージ
    @Published var chatMessages = [ChatMessage]()               // 全メッセージ
    @Published var storePoint: StorePoint?                      // 特定の店舗ポイント情報
    @Published var errorMessage = ""                            // エラーメッセージ
    @Published var isShowError = false                          // エラー表示有無
    @Published var alertMessage = ""                            // アラートメッセージ
    @Published var isShowAlert = false                          // アラート表示有無
    @Published var isScroll = false                             // メッセージスクロール用変数
    @Published var onIndicator = false                          // インジケーターが進行中か否か
    @Published var isQrCodeScanError = false                    // QRコード読み取りエラー
    @Published var isNavigateConfirmEmailView = false           // メールアドレス認証画面の表示有無
    @Published var isNavigateNotConfirmEmailView = false        // メールアドレス未認証画面の表示有無
    @Published var isShowNotConfirmEmailError = false           // メールアドレス未認証エラー
    let didCompleteLoginProcess: () -> ()
    
    init(){
        self.didCompleteLoginProcess = {}
        
    }
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
    }
    
// MARK: - Fetch
    
    /// 現在ユーザー情報を取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchCurrentUser() {
        onIndicator = true
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.handleError(String.failureFetchUID, error: nil)
            return
        }
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .getDocument { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: String.failureFetchUser)
                
                guard let data = snapshot?.data() else {
                    self.handleError(String.notFoundData, error: nil)
                    return
                }
                
                self.currentUser = .init(data: data)
                
                guard let currentUser = self.currentUser else {
                    self.handleError(String.failureFetchUser, error: nil)
                    return
                }
                
                // メールアドレス未認証の場合のエラー
                if !currentUser.isConfirmEmail && !currentUser.isStore {
                    self.isShowNotConfirmEmailError = true
                    try? FirebaseManager.shared.auth.signOut()
                }
                
                // 初回特典アラート表示
                if !currentUser.isFirstLogin && !currentUser.isStore {
                    self.handleAlert("初回登録特典として\n\(Setting.newRegistrationBenefits)ptプレゼント！")
                    let data = [FirebaseConstants.isFirstLogin: true,]
                    self.updateUsers(document: currentUser.uid, data: data)
                }
                
                self.onIndicator = false
//                print("[CurrentUser]\n \(String(describing: self.currentUser))\n")
            }
    }
    
    /// UIDに一致するユーザー情報を取得
    /// - Parameters:
    ///   - uid: トーク相手のUID
    /// - Returns: なし
    func fetchUser(uid: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .getDocument { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: String.failureFetchUser)
                
                guard let data = snapshot?.data() else {
                    self.isQrCodeScanError = true
                    self.handleError(String.notFoundData, error: nil)
                    return
                }
                self.chatUser = .init(data: data)
//                print("[ChatUser]\n \(String(describing: self.chatUser))\n")
            }
    }
    
    /// 全ユーザーを取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchAllUsers() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
            if error != nil {
                self.handleNetworkError(error: error, errorMessage: "全ユーザーの取得に失敗しました。")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                
                // 追加するユーザーが自分以外の場合のみ、追加する。
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.allUsers.append(.init(data: data))
                }
            })
        }
    }
    
    /// 最新メッセージを取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        self.recentMessages.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.message)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print("最新メッセージの取得に失敗しました。")
                    return
                }
//                self.handleNetworkError(error: error, errorMessage: "最新メッセージの取得に失敗しました。")
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                        let rm = try change.document.data(as: RecentMessage.self)
                        self.recentMessages.insert(rm, at: 0)
                    } catch {
                        self.handleError(String.notFoundData, error: nil)
                        return
                    }
                })
//                print("[RecentMessage]\n \(String(describing: self.recentMessages))\n")
            }
    }
    
    /// メッセージを取得
    /// - Parameters:
    ///   - toId: トーク相手のUID
    /// - Returns: なし
    func fetchMessages(toId: String) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        chatMessages.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print("メッセージの取得に失敗しました。")
                    return
                }
//                self.handleNetworkError(error: error, errorMessage: "メッセージの取得に失敗しました。")
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let cm = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(cm)
                        } catch {
                            self.handleError(String.notFoundData, error: nil)
                            return
                        }
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isScroll.toggle()
                }
//                print("[Message]\n \(String(describing: self.chatMessages))\n")
//                print("[Message] \n")
            }
    }
    
    /// UIDに一致する友達情報を取得
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func fetchFriend(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .getDocument { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: "このユーザーはあなたと縁を切りました。")
                
                guard let data = snapshot?.data() else {
                    self.handleError("このユーザーはあなたと縁を切りました。", error: nil)
                    return
                }
                self.friend = .init(data: data)
//                print("[Friend]\n \(String(describing: self.friend))\n")
            }
    }
    
    /// 友達情報を取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchFriends() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        self.friends.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(uid)
            .collection(FirebaseConstants.user)
            .order(by: FirebaseConstants.username)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print("友達情報の取得に失敗しました。")
                    return
                }
//                self.handleNetworkError(error: error, errorMessage: "友達情報の取得に失敗しました。")
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let fr = try change.document.data(as: Friend.self)
                            self.friends.append(fr)
                        } catch {
                            self.handleError(String.notFoundData, error: nil)
                            return
                        }
                    }
                })
//                print("[Friend]\n \(String(describing: self.friends))\n")
            }
    }
    
    /// UIDに一致する店舗ポイント情報を取得
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func fetchStorePoint(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.storePoints)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .getDocument { snapshot, error in
                
                guard let data = snapshot?.data() else {
                    print(String.notFoundData)
                    return
                }
                self.storePoint = .init(data: data)
            }
    }
    
// MARK: - Handle
    
    /// 新規作成
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    ///   - username: ユーザー名
    ///   - age: 年齢
    ///   - address: 住所
    ///   - image: トップ画像
    /// - Returns: なし
    func createNewAccount(email: String, password: String, username: String, age: String, address: String, image: UIImage?) {
        onIndicator = true
        // メールアドレス、パスワードどちらかが空白の場合、エラーを出す。
        if email.isEmpty || password.isEmpty {
            self.handleError(String.emptyEmailOrPassword, error: nil)
            return
        }
        
        // パスワードの文字数が足りない時にエラーを発動。
//        if password.count < Setting.minPasswordOfDigits {
//            self.isShowPasswordOfDigitsError = true
//            return
//        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .weakPassword:
                    self.handleError(String.weakPassword, error: error)
                    return
                case .emailAlreadyInUse:
                    self.handleError(String.emailAlreadyInUse, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                default:
                    self.handleError(error.domain, error: error)
                    return
                }
            }
            
            if image == nil {
                self.persistUsers(email: email, username: username, age: age, address: address, imageProfileUrl: nil)
            } else {
                self.persistImage(email: email, username: username, age: age, address: address, image: image)
            }
            
            self.onIndicator = false
            self.handleEmailVerification()
        }
    }
    
    /// メール送信処理
    /// - Parameters: なし
    /// - Returns: なし
    func handleEmailVerification() {
        guard let user = FirebaseManager.shared.auth.currentUser else {
            self.handleError(String.failureFetchUser, error: nil)
            return
        }
        user.sendEmailVerification { error in
            self.handleNetworkError(error: error, errorMessage: "メール送信に失敗しました。")
            return
        }
        self.isNavigateConfirmEmailView = true
    }
    
    /// サインイン
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    /// - Returns: なし
    func handleSignIn(email: String, password: String) {
        onIndicator = true
        // メールアドレス、パスワードどちらかが空白の場合、エラーを出す。
        if email.isEmpty || password.isEmpty {
            self.handleError(String.emptyEmailOrPassword, error: nil)
            return
        }
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .userNotFound, .wrongPassword:
                    self.handleError(String.userNotFound, error: error)
                    return
                case .userDisabled:
                    self.handleError(String.userDisabled, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                default:
                    self.handleError(error.domain, error: error)
                    return
                }
            }
            
            self.onIndicator = false
            self.didCompleteLoginProcess()
        }
    }
    
    /// サインイン（メールアドレス認証含む）
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    /// - Returns: なし
    func handleSignInWithConfirmEmail(email: String, password: String) {
        onIndicator = true
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .userNotFound, .wrongPassword:
                    self.handleError(String.userNotFound, error: error)
                    return
                case .userDisabled:
                    self.handleError(String.userDisabled, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                default:
                    self.handleError(error.domain, error: error)
                    return
                }
            }
            
            guard let user = result?.user else {
                self.handleError(String.failureFetchUser, error: nil)
                return
            }
            
            // メールアドレス認証済みかの確認
            if !user.isEmailVerified {
                self.handleError("メールアドレスの認証が完了していません。\n再度メールを送信する場合は、下の「メールを再送する」を押してください。", error: error)
                try? FirebaseManager.shared.auth.signOut()
                return
            }
            
            // メールアドレス認証済み処理
            let data = [FirebaseConstants.isConfirmEmail: true,]
            self.updateUsers(document: user.uid, data: data)
            
            self.onIndicator = false
            self.didCompleteLoginProcess()
        }
    }
    
    /// サインイン（メール送信含む）
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    /// - Returns: なし
    func handleSignInWithEmailVerification(email: String, password: String) {
        onIndicator = true
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .userNotFound, .wrongPassword:
                    self.handleError(String.userNotFound, error: error)
                    return
                case .userDisabled:
                    self.handleError(String.userDisabled, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                default:
                    self.handleError(error.domain, error: error)
                    return
                }
            }
            
            guard let user = result?.user else {
                self.handleError(String.failureFetchUser, error: nil)
                return
            }
            
            user.sendEmailVerification { error in
                self.handleNetworkError(error: error, errorMessage: "メール送信に失敗しました。")
                return
            }
            self.isNavigateConfirmEmailView = true
            self.onIndicator = false
        }
    }
    
//    func signInWithEmailLink(email: String, link: String) {
//        Auth.auth().signIn(withEmail: email, link: link) { user, error in
//            self.handleNetworkError(error: error, errorMessage: "メールアドレス認証に失敗しました。")
//        }
//    }
    
    /// テキスト送信処理
    /// - Parameters:
    ///   - toId: 受信者UID
    ///   - chatText: ユーザーの入力テキスト
    ///   - lastText: 一時保存用最新メッセージ
    ///   - isSendPay: 送金の有無
    /// - Returns: なし
    func handleSend(toId: String, chatText: String, lastText: String, isSendPay: Bool) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let messageData = [FirebaseConstants.fromId: fromId,
                           FirebaseConstants.toId: toId,
                           FirebaseConstants.text: (isSendPay ? lastText : chatText),
                           FirebaseConstants.isSendPay: isSendPay,
                           FirebaseConstants.timestamp:
                            Timestamp()] as [String : Any]
        
        // 自身のメッセージデータを保存
        let messageDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        messageDocument.setData(messageData) { error in
            if error != nil {
                self.handleError("メッセージの保存に失敗しました。", error: error)
                return
            }
        }
        
        // トーク相手のメッセージデータを保存
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if error != nil {
                self.handleError("メッセージの保存に失敗しました。", error: error)
                return
            }
        }
        
        // 自身のメッセージデータを保存
        guard let chatUser = chatUser else { return }
        persistRecentMessage(user: chatUser, isSelf: true, fromId: fromId, toId: toId, text: isSendPay ? lastText : chatText, isSendPay: isSendPay)
        
        // トーク相手のメッセージデータを保存
        guard let currentUser = currentUser else { return }
        persistRecentMessage(user: currentUser, isSelf: false, fromId: fromId, toId: toId, text: isSendPay ? lastText : chatText, isSendPay: isSendPay)
    }
    
    /// ネットワークエラー処理
    /// - Parameters:
    ///   - error: エラー
    ///   - errorMessage: エラーメッセージ
    /// - Returns: なし
    func handleNetworkError(error: Error?, errorMessage: String) {
        if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
            switch errorCode {
            case .networkError:
                self.handleError(String.networkError, error: error)
                return
            default:
                self.handleError(errorMessage, error: error)
                return
            }
        }
    }
    
    /// エラー処理
    /// - Parameters:
    ///   - errorMessage: エラーメッセージ
    /// - Returns: なし
    func handleError(_ errorMessage: String, error: Error?) {
        self.onIndicator = false
        self.errorMessage = errorMessage
        self.isShowError = true
        // エラーメッセージ
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else {
            print("Error: \(errorMessage)")
        }
    }
    
    /// アラート
    /// - Parameters:
    ///   - message: メッセージ
    /// - Returns: なし
    func handleAlert(_ message: String) {
        self.onIndicator = false
        self.alertMessage = message
        self.isShowAlert = true
    }
    
// MARK: - Persist
    
    /// ユーザー情報を保存
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    ///   - imageProfileUrl: 画像URL
    /// - Returns: なし
    func persistUsers(email: String, username: String, age: String, address: String, imageProfileUrl: URL?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.uid : uid,
                        FirebaseConstants.email: email,
                        FirebaseConstants.profileImageUrl: imageProfileUrl?.absoluteString ?? "",
                        FirebaseConstants.money: Setting.newRegistrationBenefits,
                        FirebaseConstants.username: username == "" ? email : username,
                        FirebaseConstants.age: age,
                        FirebaseConstants.address: address,
                        FirebaseConstants.isConfirmEmail: false,
                        FirebaseConstants.isFirstLogin: false,
                        FirebaseConstants.isStore: false,
                        FirebaseConstants.isOwner: false,
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .setData(userData) { error in
                if error != nil {
                    // Authを削除
                    self.deleteAuth()
                    // 画像が保存済みであれば画像を削除
                    if let imageProfileUrl {
                        self.deleteImage(withPath: imageProfileUrl.absoluteString)
                    }
                    self.handleError("ユーザー情報の保存に失敗しました。", error: error)
                    return
                }
//                Analytics.logEvent("user_information", parameters: [
//                  "age": age as NSObject,
//                  "address": address as NSObject,
//                ])
//                Analytics.setUserProperty(age, forName: "age")
//                Analytics.setUserProperty(address, forName: "address")
//                self.didCompleteLoginProcess()
            }
    }
    
    /// 画像を保存
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    ///   - image: トップ画像
    /// - Returns: なし
    func persistImage(email: String, username: String, age: String, address: String, image: UIImage?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { _, error in
            if error != nil {
                self.deleteAuth()
                self.handleError("画像の保存に失敗しました。", error: error)
                return
            }
            // Firestore Databaseに保存するためにURLをダウンロードする。
            ref.downloadURL { url, error in
                if error != nil {
                    self.deleteAuth()
                    self.handleError("画像URLの取得に失敗しました。", error: error)
                    return
                }
                guard let url = url else { return }
                self.persistUsers(email: email, username: username, age: age, address: address, imageProfileUrl: url)
            }
        }
    }
    
    /// 最新メッセージを保存
    /// - Parameters:
    ///   - user: トーク相手のデータ
    ///   - isSelf: 自身のデータか否か
    ///   - fromId: 送信者UID
    ///   - toId: 受信者UID
    ///   - text: テキスト
    ///   - isSendPay: 送金の有無
    /// - Returns: なし
    private func persistRecentMessage(user: ChatUser, isSelf: Bool, fromId: String, toId: String, text: String, isSendPay: Bool) {
        let document: DocumentReference
        
        // 自身のデータか、トーク相手のデータかでドキュメントを変える。
        if isSelf {
            document = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.recentMessages)
                .document(fromId)
                .collection(FirebaseConstants.message)
                .document(toId)
        } else {
            document = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.recentMessages)
                .document(toId)
                .collection(FirebaseConstants.message)
                .document(fromId)
        }
        
        let data = [
            FirebaseConstants.email: user.email,
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: user.profileImageUrl,
            FirebaseConstants.isSendPay: isSendPay,
            FirebaseConstants.username: user.username,
            FirebaseConstants.timestamp: Timestamp(),
        ] as [String : Any]
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("最新メッセージの保存に失敗しました。", error: error)
                return
            }
        }
    }
    
    /// 友達情報を保存
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func persistFriends(document1: String, document2: String, data: [String: Any]) {
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("友達の保存に失敗しました。", error: error)
                return
            }
        }
    }
    
    /// 店舗ポイント情報を保存
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func persistStorePoints(document1: String, document2: String,  data: [String: Any]) {
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.storePoints)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("店舗ポイント情報の保存に失敗しました。", error: error)
                return
            }
        }
    }
    
// MARK: - Update
    
    /// ユーザー情報を更新
    /// - Parameters:
    ///   - document: ドキュメント
    ///   - data: データ
    /// - Returns: なし
    func updateUsers(document: String, data: [String: Any]) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(document)
            .updateData(data as [AnyHashable : Any]) { error in
                self.handleNetworkError(error: error, errorMessage: "ユーザー情報の更新に失敗しました。")
            }
    }
    
    /// 最新メッセージを更新
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func updateRecentMessages(document1: String, document2: String, data: [String: Any]) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(document1)
            .collection(FirebaseConstants.message)
            .document(document2)
            .updateData(data as [AnyHashable : Any]) { error in
                self.handleNetworkError(error: error, errorMessage: "最新メッセージの更新に失敗しました。")
            }
    }
    
    /// 友達情報を更新
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func updateFriends(document1: String, document2: String, data: [String: Any]) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .updateData(data as [AnyHashable : Any]) { error in
                self.handleNetworkError(error: error, errorMessage: "ユーザー情報の更新に失敗しました。")
            }
    }
    
    /// パスワードを更新
    /// - Parameters:
    ///   - password: パスワード
    /// - Returns: なし
    func updatePassword(password: String) {
        FirebaseManager.shared.auth.currentUser?.updatePassword(to: password) { error in
            self.handleNetworkError(error: error, errorMessage: "パスワードの更新に失敗しました。")
        }
    }
    
// MARK: - Delete
    
    /// ユーザー情報を削除
    /// - Parameters:
    ///   - document: ドキュメント
    /// - Returns: なし
    func deleteUsers(document: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(document)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteData)
            }
    }
    
    /// メッセージを削除
    /// - Parameters:
    ///   - document: ドキュメント
    ///   - collection: コレクション
    /// - Returns: なし
    func deleteMessages(document: String, collection: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(document)
            .collection(collection)
            .getDocuments { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteData)
                for document in snapshot!.documents {
                    document.reference.delete { error in
                        if error != nil {
                            self.handleError(String.failureDeleteData, error: error)
                            return
                        }
                    }
                }
            }
    }
    
    /// 最新メッセージを削除
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func deleteRecentMessage(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(document1)
            .collection(FirebaseConstants.message)
            .document(document2)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteData)
            }
    }
    
    /// 友達情報を削除
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func deleteFriend(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteData)
            }
    }
    
    /// 画像を削除
    /// - Parameters:
    ///   - withPath: 削除するパス
    /// - Returns: なし
    func deleteImage(withPath: String) {
        if let stringImage = currentUser?.profileImageUrl {
            // 画像が設定されていない場合、この処理をスキップする。
            if stringImage != "" {
                let ref = FirebaseManager.shared.storage.reference(withPath: withPath)
                ref.delete { error in
                    self.handleNetworkError(error: error, errorMessage: String.failureDeleteData)
                }
            }
        }
    }
    
    /// Auth削除
    /// - Parameters: なし
    /// - Returns: なし
    func deleteAuth() {
        FirebaseManager.shared.auth.currentUser?.delete { error in
            self.handleNetworkError(error: error, errorMessage: String.failureDeleteData)
        }
    }
    
    /// サインイン失敗時のデータ削除
    /// - Parameters: なし
    /// - Returns: なし
    func deleteData() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        // ユーザー情報削除
        deleteUsers(document: uid)
        // 画像削除
        deleteImage(withPath: uid)
        // Auth削除
        deleteAuth()
    }
    
// MARK: - Other

    /// QRコードを生成する
    /// - Parameters:
    ///   - inputText: QRコードの生成に使用するテキスト
    /// - Returns: QRコード画像
    func generateQRCode(inputText: String) -> UIImage? {
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }
        
        let inputData = inputText.data(using: .utf8)
        qrFilter.setValue(inputData, forKey: "inputMessage")
        // 誤り訂正レベルをHに指定
        qrFilter.setValue("L", forKey: "inputCorrectionLevel")
        
        guard let ciImage = qrFilter.outputImage else { return nil }
        
        // CIImageは小さい為、任意のサイズに拡大。
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCiImage = ciImage.transformed(by: sizeTransform)
        
        // CIImageだとSwiftUIのImageでは表示されない為、CGImageに変換。
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledCiImage,
                                                  from: scaledCiImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }


    /// Date型を日付のみ取り出す
    /// - Parameters:
    ///   - date: 変換する日付
    /// - Returns: 日付のみのDate
    func dateFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

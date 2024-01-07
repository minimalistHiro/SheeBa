//
//  SetUpEmailView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/21.
//

import SwiftUI
import FirebaseAuth

struct SetUpEmailView: View {
    
    @FocusState var focus: Bool
//    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ViewModel
    let didCompleteLoginProcess: () -> ()
//    @State private var link = ""                        // リンク
    @State private var isShowSendEmailAlert = false     // メール送信確認アラート
    @State private var isShowCloseAlert = false         // 画面戻り確認アラート
    @State private var isShowPassword = false           // パスワード表示有無
    @State private var isShowPassword2 = false          // 確認用パスワード表示有無
    
    // DB
    @State private var email: String = ""               // メールアドレス
    @State private var password: String = ""            // パスワード
    @State private var password2: String = ""           // 確認用パスワード
    @Binding var username: String
    @Binding var age: String
    @Binding var address: String
    @Binding var image: UIImage?
    
    // ボタンの有効性
    var disabled: Bool {
        if !password.isEmpty && !email.isEmpty {
            // パスワードが入力済みで、確認用パスワードと一致していた場合のみ押下可能。
            if password == password2 {
                return false
            }
        }
        return true
    }
    
    init(username: Binding<String>,
         age: Binding<String>,
         address: Binding<String>,
         image: Binding<UIImage?>,
         didCompleteLoginProcess: @escaping () -> ())
    {
        self._username = username
        self._age = age
        self._address = address
        self._image = image
        self.didCompleteLoginProcess = didCompleteLoginProcess
        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                InputText.InputTextField(focus: $focus, editText: $email, titleText: "メールアドレス", textType: .email)
                
                InputText.InputPasswordTextField(focus: $focus, editText: $password, titleText: "パスワード", isShowPassword: $isShowPassword)
                
                InputText.InputPasswordTextField(focus: $focus, editText: $password2, titleText: "パスワード（確認用）", isShowPassword: $isShowPassword2)
                
                Spacer()
                
                Button {
                    vm.createNewAccount(email: email, password: password, username: username, age: age, address: address, image: image)
                } label: {
                    CustomCapsule(text: "メール送信", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
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
            .navigationTitle("新規アカウントを作成")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
            .navigationDestination(isPresented: $vm.isNavigateConfirmEmailView) {
                ConfirmEmailView(email: $email, password: $password, didCompleteLoginProcess: didCompleteLoginProcess)
            }
        }
//        .onOpenURL { url in
//            email = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
//
//            let link = url.absoluteString
//            isNavigateSetUpPasswordView = true
            
//            if FirebaseManager.shared.auth.isSignIn(withEmailLink: link) {
//                passwordlessSignIn(email: email, link: link) { result in
//                    switch result {
//                    case let .success(user):
//                        isNavigateSetUpPasswordView = user?.isEmailVerified ?? falseｒ
//                    case let .failure(error):
//                        isNavigateSetUpPasswordView = false
//                        vm.handleNetworkError(error: error, errorMessage: "認証エラーが発生しました。")
//                    }
//                }
//            }
//        }
        .asBackButton()
//        .asAlertBackButton {
//            // メールが送信済みの場合のみアラートを発動
//            if isSendEmail {
//                isShowCloseAlert = true
//            } else {
////                dismiss()
//            }
//        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
//        .asSingleAlert(title: "",
//                       isShowAlert: $isShowSendEmailAlert,
//                       message: "入力したメールアドレスにパスワード設定用のURLを送信しました。",
//                       didAction: {
//            isShowSendEmailAlert = false
//            isNavigateConfirmEmailView = true
//        })
//        .asDestructiveAlert(title: "",
//                            isShowAlert: $isShowCloseAlert,
//                            message: "送信したメールリンクが無効になりますがよろしいですか？",
//                            buttonText: "戻る") {
//            dismiss()
//        }
    }
    
    // メールでの認証コード送信を実行する関数
//    private func sendEmailVerification(email: String) {
//        tempCode = generateRandomCode()
//        
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
////            mail.mailComposeDelegate = self
//            mail.setToRecipients([email])
//            mail.setSubject("あなたの認証コード")
//            mail.setMessageBody("あなたの認証コードは\(tempCode)です", isHTML: false)
//            
//        } else {
//            print("メールを送信できません")
//        }
//    }
    
    // ランダムな認証コードを生成する関数
//    private func generateRandomCode() -> String {
//        return String(arc4random_uniform(899999) + 100000)
//    }
    
    /// 入力したメールアドレスにパスワード設定リンクを送る
    /// - Parameters:
    ///   - email: メールアドレス
    /// - Returns: なし
//    private func sendSignUpLink(email: String) {
//        let actionCodeSettings = ActionCodeSettings()
//        actionCodeSettings.url = URL(string: "https://sheeba.com/signin")
//        actionCodeSettings.handleCodeInApp = true
//        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
//        
//        FirebaseManager.shared.auth.sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
//            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
//                switch errorCode {
//                case .invalidEmail:
//                    vm.handleError(String.invalidEmail, error: error)
//                    return
//                case .emailAlreadyInUse:
//                    vm.handleError(String.emailAlreadyInUse, error: error)
//                    return
//                case .networkError:
//                    vm.handleError(String.networkError, error: error)
//                    return
//                default:
//                    vm.handleError(error.localizedDescription, error: error)
//                    return
//                }
//            }
//            isShowSendEmailAlert = true
////            UserDefaults.standard.setValue(email, forKey: "Email")
////            isSendEmail = true
//        }
//    }
    
//    private func passwordlessSignIn(email: String, link: String, completion: @escaping (Result<User?, Error>) -> Void) {
//        FirebaseManager.shared.auth.signIn(withEmail: email, link: link) { result, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription).")
//                completion(.failure(error))
//            } else {
//                completion(.success(result?.user))
//            }
//        }
//    }
}

#Preview {
    SetUpEmailView(username: .constant(String.previewUsername),
                   age: .constant(String.previewAge),
                   address: .constant(String.previewAddress),
                   image: .constant(nil),
                   didCompleteLoginProcess: {})
}

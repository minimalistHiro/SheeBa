//
//  SendEmailView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/27.
//

import SwiftUI
import FirebaseAuth

struct SendEmailView: View {
    
    @Environment(\.dismiss) var dismiss
    @FocusState var focus: Bool
    @ObservedObject var vm: ViewModel
    let didCompleteLoginProcess: () -> ()
    @State private var isShowSendEmailAlert = false     // メール送信確認アラート
    
    // DB
    @State private var email: String = ""               // メールアドレス
    
    var disabled: Bool {
        self.email.isEmpty
    }                                                   // ボタンの有効性
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                InputText.InputTextField(focus: $focus, editText: $email, titleText: "メールアドレス", textType: .email)
                
                Spacer()
                
                Button {
                    sendResetPasswordLink(email: email)
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
            .navigationTitle("メールアドレスを入力")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
        }
        .asBackButton()
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowSendEmailAlert,
                       message: "入力したメールアドレスにパスワード再設定用のURLを送信しました。",
                       didAction: {
            isShowSendEmailAlert = false
            dismiss()
        })
    }
    
    /// 入力したメールアドレスにパスワード再設定リンクを送る
    /// - Parameters:
    ///   - email: メールアドレス
    /// - Returns: なし
    private func sendResetPasswordLink(email: String) {
        FirebaseManager.shared.auth.sendPasswordReset(withEmail: email) { error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    vm.handleError(String.invalidEmail, error: error)
                    return
                case .userNotFound:
                    vm.handleError(String.wrongEmail, error: error)
                    return
                case .networkError:
                    vm.handleError(String.networkError, error: error)
                    return
                default:
                    vm.handleError(error.domain, error: error)
                    return
                }
            }
            isShowSendEmailAlert = true
        }
    }
}

#Preview {
    SendEmailView(didCompleteLoginProcess: {})
}

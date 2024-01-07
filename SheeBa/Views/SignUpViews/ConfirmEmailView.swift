//
//  ConfirmEmailView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/05.
//

import SwiftUI

struct ConfirmEmailView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ViewModel
    let didCompleteLoginProcess: () -> ()
    @State private var isShowDeleteDataAlert = false            // データ削除アラートの表示有無
    @State private var isShowSendEmailAlert = false             // メール送信アラート
    
    // DB
    @Binding var email: String
    @Binding var password: String
    
    init(email: Binding<String>,
         password: Binding<String>,
         didCompleteLoginProcess: @escaping () -> ()) {
        self._email = email
        self._password = password
        self.didCompleteLoginProcess = didCompleteLoginProcess
        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("入力したメールアドレスに\n確認用メールを送信しました。")
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                Spacer()
                
                Text("送信したメールアドレス内のリンクを開き、メールアドレスの認証を完了してください。")
                    .lineSpacing(10)
                    .font(.callout)
                    .padding(.horizontal)
                
                Spacer()
                Spacer()
                
                Button {
                    vm.handleSignInWithConfirmEmail(email: email, password: password)
                } label: {
                    CustomCapsule(text: "メールアドレス認証済み", imageSystemName: nil, foregroundColor: .black, textColor: .white, isStroke: false)
                }
                
                Spacer()
                
                Button {
                    vm.handleSignInWithEmailVerification(email: email, password: password)
//                    vm.handleEmailVerification()
                    isShowSendEmailAlert = true
                } label: {
                    Text("メールを再送する")
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                Spacer()
            }
            .navigationTitle("新規アカウントを作成")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
        }
        .asAlertBackButton {
            isShowDeleteDataAlert = true
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowSendEmailAlert,
                       message: "入力したメールアドレスに確認用メールを送信しました。",
                       didAction: { isShowSendEmailAlert = false })
        .asDestructiveAlert(title: "", isShowAlert: $isShowDeleteDataAlert, message: "戻ると送信したメールアドレスのリンクが無効になりますがよろしいですか？", buttonText: "はい", didAction: {
            dismiss()
        })
    }
}

#Preview {
    ConfirmEmailView(email: .constant(String.previewEmail),
                     password: .constant(String.previewPassword),
                     didCompleteLoginProcess: {})
}

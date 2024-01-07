//
//  NotConfirmEmailView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/07.
//

import SwiftUI

struct NotConfirmEmailView: View {
    
    @FocusState var focus: Bool
    @ObservedObject var vm: ViewModel
    let didCompleteLoginProcess: () -> ()
    @State private var isShowPassword = false           // パスワード表示有無
    
    // DB
    @State private var email: String = ""               // メールアドレス
    @State private var password: String = ""            // パスワード
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
    }
    
    // ボタンの有効性
    var disabled: Bool {
        email.isEmpty || password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("メールアドレス、パスワードを入力し、「メール送信」ボタンを押してメールアドレス認証を完了してください。")
                    .lineSpacing(10)
                    .font(.callout)
                    .padding(.horizontal)
                
                Spacer()
                
                InputText.InputTextField(focus: $focus, editText: $email, titleText: "メールアドレス", textType: .email)
                
                InputText.InputPasswordTextField(focus: $focus, editText: $password, titleText: "パスワード", isShowPassword: $isShowPassword)
                
                Spacer()
                
                Button {
                    vm.handleSignInWithEmailVerification(email: email, password: password)
                } label: {
                    CustomCapsule(text: "メール送信", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                }
                .disabled(disabled)
                
                Spacer()
            }
            // タップでキーボードを閉じるようにするため
            .contentShape(Rectangle())
            .onTapGesture {
                focus = false
            }
            .navigationTitle("メールアドレス認証")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
            .navigationDestination(isPresented: $vm.isNavigateConfirmEmailView) {
                ConfirmEmailView(email: $email, password: $password, didCompleteLoginProcess: didCompleteLoginProcess)
            }
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
    }
}

#Preview {
    NotConfirmEmailView(didCompleteLoginProcess: {})
}

//
//  LoginView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/09.
//

import SwiftUI

struct LoginView: View {
    
    @FocusState var focus: Bool
    @ObservedObject var vm: ViewModel
    let didCompleteLoginProcess: () -> ()
    @State private var isShowPassword = false                   // パスワード表示有無
    @State private var isNavigateSendEmailView = false          // メール送信画面の表示有無
    
    // DB
    @State private var email: String = ""               // メールアドレス
    @State private var password: String = ""            // パスワード
    
    var disabled: Bool {
        self.email.isEmpty || self.password.isEmpty
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
                
                InputText.InputPasswordTextField(focus: $focus, editText: $password, titleText: "パスワード", isShowPassword: $isShowPassword)
                
                Spacer()
                
                Button {
                    vm.handleSignIn(email: email, password: password)
                } label: {
                    CustomCapsule(text: "ログイン", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                }
                .disabled(disabled)
                
                Spacer()
                
                Button {
                    isNavigateSendEmailView = true
                } label: {
                    Text("パスワードを忘れた方はこちら")
                        .foregroundStyle(.blue)
                }
//                NavigationLink {
//                    SendEmailView(didCompleteLoginProcess: didCompleteLoginProcess)
//                } label: {
//                    Text("パスワードを忘れた方はこちら")
//                        .foregroundStyle(.blue)
//                }
                
                Spacer()
            }
            // タップでキーボードを閉じるようにするため
            .contentShape(Rectangle())
            .onTapGesture {
                focus = false
            }
            .navigationTitle("ログイン")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
            .navigationDestination(isPresented: $isNavigateSendEmailView) {
                SendEmailView(didCompleteLoginProcess: didCompleteLoginProcess)
            }
        }
        .asBackButton()
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
    }
}

#Preview {
    LoginView(didCompleteLoginProcess: {})
}

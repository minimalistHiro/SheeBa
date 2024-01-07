////
////  ResetPasswordView.swift
////  CocoShibaTsuka
////
////  Created by 金子広樹 on 2023/12/28.
////
//
//import SwiftUI
//
//struct ResetPasswordView: View {
//    
//    @FocusState var focus: Bool
//    @ObservedObject var vm: ViewModel
//    let didCompleteLoginProcess: () -> ()
//    @State private var isShowPassword = false           // パスワード表示有無
//    @State private var isShowPassword2 = false          // 確認用パスワード表示有無
//    
//    // DB
//    @State private var password: String = ""            // パスワード
//    @State private var password2: String = ""           // 確認用パスワード
//    @Binding var email: String
//    
//    var disabled: Bool {
//        if !password.isEmpty {
//            // パスワードが入力済みで、確認用パスワードと一致していた場合のみ押下可能。
//            if password == password2 {
//                return false
//            }
//        }
//        return true
//    }                                                   // ボタンの有効性
//    
//    init(email: Binding<String>,
//         didCompleteLoginProcess: @escaping () -> ())
//    {
//        self._email = email
//        self.didCompleteLoginProcess = didCompleteLoginProcess
//        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Spacer()
//                
//                InputText.InputPasswordTextField(focus: $focus, editText: $password, titleText: "パスワード", isShowPassword: $isShowPassword)
//                
//                InputText.InputPasswordTextField(focus: $focus, editText: $password2, titleText: "パスワード（確認用）", isShowPassword: $isShowPassword2)
//                
//                Spacer()
//                
//                Button {
//                    vm.updatePassword(password: password)
//                    vm.handleSignIn(email: email, password: password)
//                } label: {
//                    CustomCapsule(text: "パスワードを設定してログイン", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
//                }
//                .disabled(disabled)
//                
//                Spacer()
//                Spacer()
//            }
//            // タップでキーボードを閉じるようにするため
//            .contentShape(Rectangle())
//            .onTapGesture {
//                focus = false
//            }
//            .navigationTitle("パスワードを再設定")
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarBackButtonHidden(true)
//            .overlay {
//                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
//            }
//        }
//        .asSingleAlert(title: "",
//                        isShowAlert: $vm.isShowError,
//                        message: vm.errorMessage,
//                        didAction: { vm.isShowError = false })
//    }
//}
//
//#Preview {
//    ResetPasswordView(email: .constant(String.previewEmail),
//                      didCompleteLoginProcess: {})
//}

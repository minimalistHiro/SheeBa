////
////  SetUpPhoneView.swift
////  SheeBa
////
////  Created by 金子広樹 on 2024/01/05.
////
//
//import SwiftUI
//import FirebaseAuth
//
//struct SetUpPhoneView: View {
//    
//    @FocusState var focus: Bool
//    @ObservedObject var vm: ViewModel
//    let didCompleteLoginProcess: () -> ()
//    @State private var isShowSendSMSAlert = false       // SMS送信確認アラート
//    @State private var isNavigateSMSAuthView = false    // SMS認証画面の表示有無
//    
//    // DB
//    @State private var phoneNumber: String = ""         // 電話番号
//    @Binding var username: String
//    @Binding var age: String
//    @Binding var address: String
//    @Binding var image: UIImage?
//    
//    // ボタンの有効性
//    var disabled: Bool {
//        self.phoneNumber.isEmpty
//    }
//    
//    init(username: Binding<String>,
//         age: Binding<String>,
//         address: Binding<String>,
//         image: Binding<UIImage?>,
//         didCompleteLoginProcess: @escaping () -> ())
//    {
//        self._username = username
//        self._age = age
//        self._address = address
//        self._image = image
//        self.didCompleteLoginProcess = didCompleteLoginProcess
//        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Spacer()
//                
//                InputText.InputTextField(focus: $focus, editText: $phoneNumber, titleText: "電話番号", textType: .phone)
//                
//                Spacer()
//                
//                Button {
//                    if Setting.isTest {
//                        sendAuthNumberToSMSTest()
//                    } else {
//                        sendAuthNumberToSMS()
//                    }
//                } label: {
//                    CustomCapsule(text: "認証する", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
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
//            .navigationTitle("電話番号を設定")
//            .navigationBarTitleDisplayMode(.inline)
//            .overlay {
//                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
//            }
//            .navigationDestination(isPresented: $isNavigateSMSAuthView) {
//                SMSAuthView()
//            }
//        }
//        .asBackButton()
//        .asSingleAlert(title: "",
//                       isShowAlert: $vm.isShowError,
//                       message: vm.errorMessage,
//                       didAction: { vm.isShowError = false })
//        .asSingleAlert(title: "",
//                       isShowAlert: $isShowSendSMSAlert,
//                       message: "入力した電話番号に6桁の認証コードを送信しました。",
//                       didAction: {
//            isNavigateSMSAuthView = true
//        })
//    }
//    
//    /// 入力した電話番号に6桁認証番号をSMS送信する
//    /// - Parameters:
//    ///   - phoneNumber: 電話番号
//    /// - Returns: なし
//    private func sendAuthNumberToSMS() {
//        phoneNumber.removeFirst()
//        let phoneNumber = "+81" + phoneNumber
//        print(phoneNumber)
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
//            if let error = error {
//                vm.handleNetworkError(error: error, errorMessage: "SMS送信に失敗しました。")
//                return
//            }
//            //ユーザーデフォルトにverificationIDをセット
//            UserDefaults.standard.set(verificationID, forKey: String.authVerificationID)
//        }
//        isShowSendSMSAlert = true
//    }
//    
//    /// 入力した電話番号に6桁認証番号をSMS送信する（テスト用）
//    /// - Parameters: なし
//    /// - Returns: なし
//    private func sendAuthNumberToSMSTest() {
//        let phoneNumber = "+16505553434"
////        let phoneNumber = "+818062571616"
//        
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
//            if let error = error {
//                vm.handleNetworkError(error: error, errorMessage: "SMS送信に失敗しました。")
//                return
//            }
//            //ユーザーデフォルトにverificationIDをセット
//            UserDefaults.standard.set(verificationID, forKey: String.authVerificationID)
//        }
//        
////        guard let verificationID = UserDefaults.standard.string(forKey: String.authVerificationID) else {
////            return
////        }
////        let verificationCode = "123456"
////        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
////        FirebaseManager.shared.auth.signIn(with: credential) { (authResult, error) in
////            if let error = error {
////                print("失敗")
////                return
////            }
////            if let authResult = authResult {
////                print("失敗？")
////            }
////        }
//
//        isShowSendSMSAlert = true
//    }
//}
//
//#Preview {
//    SetUpPhoneView(username: .constant(String.previewUsername), 
//                   age: .constant(String.previewAge),
//                   address: .constant(String.previewAddress),
//                   image: .constant(nil),
//                   didCompleteLoginProcess: {})
//}

//
//  TextEditor.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/11/28.
//

import SwiftUI

struct InputText {
    static let shared = InputText()
    
    // 各種サイズ
    class Size {
        static let textPaddingLeading: CGFloat = 50
        static let textFieldPaddingTop: CGFloat = 12
        static let textFieldPaddingHeight: CGFloat = 25
        static let imagePaddingTrailing: CGFloat = 30
        static let rectangleFrameHeight: CGFloat = 2
        static let rectanglePaddingVertical: CGFloat = 8
        static let rectanglePaddingHorizontal: CGFloat = 25
    }
    
    let maxEmailTextFieldCount = 40             // メールアドレス最大文字数
    let maxPhoneNumberTextFieldCount = 11       // 電話番号最大文字数
    let maxUsernameTextFieldCount = 15          // ユーザーネーム最大文字数
    let maxPasswordTextFieldCount = 30          // パスワード最大文字数
    
    // 通常テキスト
    struct InputTextField: View {
        
        var focus: FocusState<Bool>.Binding
        @Binding var editText: String
        let titleText: String
        let textType: TextType
//        var isEmail: Bool
        var maxTextCount: Int {
            switch textType {
            case .email:
                InputText.shared.maxEmailTextFieldCount
            case .phone:
                InputText.shared.maxPhoneNumberTextFieldCount
            case .other:
                InputText.shared.maxUsernameTextFieldCount
            }
//            if isEmail {
//                InputText.shared.maxEmailTextFieldCount
//            } else {
//                InputText.shared.maxUsernameTextFieldCount
//            }
        }
        
        enum TextType {
            case email
            case phone
            case other
            
            var keyboardType: UIKeyboardType {
                switch self {
                case .email:
                    return .emailAddress
                case .phone:
                    return .phonePad
                case .other:
                    return .default
                }
            }
        }
        
        var body: some View {
            VStack {
                Text(titleText)
                    .font(.caption)
                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                    .padding(.leading, Size.textPaddingLeading)
                TextField("", text: $editText)
                    .focused(focus.projectedValue)
//                    .keyboardType(isEmail ? .emailAddress : .default)
                    .keyboardType(textType.keyboardType)
                    .padding(.top, Size.textFieldPaddingTop)
                    .padding(.horizontal, Size.textFieldPaddingHeight)
                    .onChange(of: editText, perform: { value in
                        // 最大文字数に達したら、それ以上書き込めないようにする
                        if value.count > maxTextCount {
                            editText.removeLast(editText.count - maxTextCount)
                        }
                    })
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: Size.rectangleFrameHeight)
                    .padding(.vertical, Size.rectanglePaddingVertical)
                    .padding(.horizontal, Size.rectanglePaddingHorizontal)
                    .padding(.bottom)
            }
        }
    }

    // パスワードテキスト
    struct InputPasswordTextField: View {
        
        var focus: FocusState<Bool>.Binding
        @Binding var editText: String
        let titleText: String
        @Binding var isShowPassword: Bool
        
        var body: some View {
            VStack {
                Text(titleText)
                    .font(.caption)
                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                    .padding(.leading, Size.textPaddingLeading)
                HStack {
                    if isShowPassword {
                        TextField("", text: $editText)
                            .focused(focus.projectedValue)
                            .keyboardType(.URL)
                            .padding(.top, Size.textFieldPaddingTop)
                            .padding(.horizontal, Size.textFieldPaddingHeight)
                            .onChange(of: editText, perform: { value in
                                // 最大文字数に達したら、それ以上書き込めないようにする
                                if value.count > InputText.shared.maxPasswordTextFieldCount {
                                    editText.removeLast(editText.count - InputText.shared.maxPasswordTextFieldCount)
                                }
                            })
                    } else {
                        SecureField("", text: $editText)
                            .focused(focus.projectedValue)
                            .keyboardType(.URL)
                            .padding(.top, Size.textFieldPaddingTop)
                            .padding(.horizontal, Size.textFieldPaddingHeight)
                            .onChange(of: editText, perform: { value in
                                // 最大文字数に達したら、それ以上書き込めないようにする
                                if value.count > InputText.shared.maxPasswordTextFieldCount {
                                    editText.removeLast(editText.count - InputText.shared.maxPasswordTextFieldCount)
                                }
                            })
                    }
                    Button {
                        isShowPassword.toggle()
                    } label: {
                        Image(systemName: isShowPassword ? "eye.fill" : "eye.slash.fill")
                            .padding(.trailing, Size.imagePaddingTrailing)
                            .foregroundColor(.black)
                    }
                }
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: Size.rectangleFrameHeight)
                    .padding(.vertical, Size.rectanglePaddingVertical)
                    .padding(.horizontal, Size.rectanglePaddingHorizontal)
                    .padding(.bottom)
            }
        }
    }
    
    struct InputPicker: View {
        
        @Binding var editText: String
        let titleText: String
        let explanationText: String
        let pickers: [String]
        
        var body: some View {
            VStack {
                Text(titleText)
                    .font(.caption)
                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                    .padding(.leading, Size.textPaddingLeading)
                HStack {
                    Text(editText.isEmpty ? explanationText : editText)
                        .foregroundStyle(editText.isEmpty ? .gray : .black)
                    Spacer()
                    Picker("", selection: $editText) {
                        ForEach(pickers, id: \.self) { picker in
                            Text(picker).tag(picker)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.gray)
                }
                .padding(.horizontal, Size.textFieldPaddingHeight)
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: Size.rectangleFrameHeight)
                    .padding(.vertical, Size.rectanglePaddingVertical)
                    .padding(.horizontal, Size.rectanglePaddingHorizontal)
                    .padding(.bottom)
            }
        }
    }
}

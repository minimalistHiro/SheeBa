//
//  StringExtension.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/08.
//

import Foundation

extension String {
    
    // Colors
    static let highlight = "Highlight"
    static let caution = "Caution"
    static let chatLogBackground = "ChatLogBackground"
    
    // Tutorial
    static func tutorialText(page: Int) -> String {
        switch page {
        case 1:
            return "しば通貨アプリを\nダウンロードしていただき\nありがとうございます"
        case 2:
            return "各店舗にあるQRコードを読み取って\nポイントを貯めることができます"
        case 3:
            return "貯まったポイントは\n豪華商品と交換することができます。"
        case 4:
            return "QRコードをたくさんスキャンして\n欲しい商品をゲットしよう！"
        default :
            return ""
        }
    }
    
    // ErrorCode
    static let emptyEmailOrPassword = "メールアドレス、パスワードを入力してください。"
    static let invalidEmail = "メールアドレスの形式が正しくありません。"
    static let weakPassword = "パスワードは6文字以上で設定してください。"
    static let emailAlreadyInUse = "このメールアドレスはすでに登録されています。"
    static let userNotFound = "メールアドレス、またはパスワードが間違っています。"
    static let wrongEmail = "メールアドレスが間違っています。"
    static let userDisabled = "このユーザーアカウントは無効化されています。"
    static let networkError = "通信エラーが発生しました。"
    static let notFoundData = "データが見つかりませんでした。"
    static let failureDeleteData = "データ削除に失敗しました。"
    static let failureFetchUID = "UIDの取得に失敗しました。"
    static let failureFetchUser = "ユーザー情報の取得に失敗しました。"
    static let failureFetchStorePoint = "店舗ポイント情報の取得に失敗しました。"
    
    // UserDefault
    static let authVerificationID = "authVerificationID"
    
    // preview
    static let previewUsername = "test"
    static let previewAge = ages.first ?? ""
    static let previewAddress = addresses.first ?? ""
    static let previewEmail = "test@gmail.com"
    static let previewPhoneNumber = "0120123456"
    static let previewPassword = "12345678"
}

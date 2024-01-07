//
//  Setting.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import SwiftUI

final class Setting {
    
    static let isTest: Bool = false                              // テストモードか否か
    
    // MARK: - キャンペーン値
    static let newRegistrationBenefits: String = "20"           // 新規登録特典。プレゼントポイント
    static let getPointFromStore: String = "1"                  // 店舗からの取得ポイント
    
    // MARK: - 各種設定
    // SendPayView
    static let minPasswordOfDigits = 8                          // パスワード最小桁数
    static let maxNumberOfDigits = 6                            // 最大送金桁数
    static let maxChatTextCount = 70                            // メッセージテキスト最大文字数
}

final class UserSetting: ObservableObject {
    @AppStorage("isShowPoint") var isShowPoint = true           // ポイントを表示する
}

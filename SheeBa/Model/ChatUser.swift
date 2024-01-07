//
//  ChatUser.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import Foundation

struct ChatUser: Hashable, Identifiable {
    var id: String { uid }
    
    let uid: String
    let email: String
    let profileImageUrl: String
    let money: String
    let username: String
    let age: String
    let address: String
    let isConfirmEmail: Bool
    let isStore: Bool
    let isOwner: Bool
    
    init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.money = data[FirebaseConstants.money] as? String ?? ""
        self.username = data[FirebaseConstants.username] as? String ?? ""
        self.age = data[FirebaseConstants.age] as? String ?? ""
        self.address = data[FirebaseConstants.address] as? String ?? ""
        self.isConfirmEmail = data[FirebaseConstants.isConfirmEmail] as? Bool ?? false
        self.isStore = data[FirebaseConstants.isStore] as? Bool ?? false
        self.isOwner = data[FirebaseConstants.isOwner] as? Bool ?? false
    }
}

let ages: [String] = [
    "",
    "〜19歳",
    "20代",
    "30代",
    "40代",
    "50代",
    "60歳〜",
]

let addresses: [String] = [
    "",
    "川口市（'芝'が付く地域）",
//    "芝新町",
//    "芝樋ノ爪",
//    "芝西",
//    "芝塚原",
//    "芝宮根町",
//    "芝中田",
//    "芝下",
//    "芝東町",
//    "芝園町",
//    "芝富士",
//    "大字芝",
    "川口市（'芝'が付かない地域）",
    "蕨市",
    "さいたま市",
    "その他",
]

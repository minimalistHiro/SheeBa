//
//  Friend.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/07.
//

import Foundation
import FirebaseFirestoreSwift

struct Friend: Hashable, Equatable, Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    let email: String
    let profileImageUrl: String
    let money: String
    let username: String
    let isApproval: Bool                // お互いに友達承認済みか否か
    let approveUid: String              // 友達承認申請者
    
    init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.money = data[FirebaseConstants.money] as? String ?? ""
        self.username = data[FirebaseConstants.username] as? String ?? ""
        self.isApproval = data[FirebaseConstants.isApproval] as? Bool ?? false
        self.approveUid = data[FirebaseConstants.approveUid] as? String ?? ""
    }
}

//
//  RecentMessage.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/17.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Equatable, Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let fromId: String
    let toId: String
    let text: String
    let profileImageUrl: String
    let isSendPay: Bool
    let username: String
    let timestamp: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

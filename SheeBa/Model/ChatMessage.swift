//
//  ChatMessage.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/16.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Equatable, Codable, Identifiable {
    @DocumentID var id: String?
    let fromId: String
    let toId: String
    let text: String
    let isSendPay: Bool
    let timestamp: Date
}

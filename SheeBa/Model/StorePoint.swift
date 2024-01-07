//
//  StorePoint.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2024/01/01.
//

import Foundation
import FirebaseFirestoreSwift

struct StorePoint: Equatable, Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    let email: String
    let profileImageUrl: String
    let getPoint: String
    let username: String
    let date: String
    
    init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.getPoint = data[FirebaseConstants.getPoint] as? String ?? ""
        self.username = data[FirebaseConstants.username] as? String ?? ""
        self.date = data[FirebaseConstants.date] as? String ?? ""
    }
}

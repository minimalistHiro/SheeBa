////
////  MailCompose.swift
////  SheeBa
////
////  Created by 金子広樹 on 2024/01/05.
////
//
//import SwiftUI
//import MessageUI
//
//class MailCompose: UIViewController, MFMailComposeViewControllerDelegate {
//    let email: String = ""
//    var tempCode: String = ""
//    
//    init(email: String) {
//        self.email = email
//    }
//    
//    // メールでの認証コード送信を実行する関数
//    func sendEmailVerification() {
//        tempCode = generateRandomCode()
//        
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
//            mail.mailComposeDelegate = self
//            mail.setToRecipients([email])
//            mail.setSubject("あなたの認証コード")
//            mail.setMessageBody("あなたの認証コードは\(tempCode)です", isHTML: false)
//            
//            present(mail, animated: true)
//        } else {
//            print("メールを送信できません")
//        }
//    }
//    
//    // ランダムな認証コードを生成する関数
//    func generateRandomCode() -> String {
//        return String(arc4random_uniform(899999) + 100000)
//    }
//}
//
//class MailCompose: UIViewControllerRepresentable {
//    typealias UIViewControllerType = <#type#>
//    
//    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> UIViewController {
//        let controller = MFMailComposeViewController()
//        controller.mailComposeDelegate = context.coordinator
//        controller.setSubject("これが件名")
//        controller.setToRecipients(["hogehoge@hogehoge.com"])
//        controller.setMessageBody("これが本文", isHTML: false)
//        return controller
//    }
//}

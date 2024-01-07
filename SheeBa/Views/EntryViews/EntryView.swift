//
//  EntryView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/11/27.
//

import SwiftUI

struct EntryView: View {
    
    @ObservedObject var vm: ViewModel
    @State private var isShowTutorialView = false               // チュートリアル表示有無
    let didCompleteLoginProcess: () -> ()
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Spacer()
                
                Text("SheeBa")
                    .font(.system(size: 50))
                
                Spacer()
                
                NavigationLink {
                    SetUpUsernameView(didCompleteLoginProcess: self.didCompleteLoginProcess)
                } label: {
                    CustomCapsule(text: "アカウントを作成する",
                                  imageSystemName: nil,
                                  foregroundColor: .white,
                                  textColor: .black,
                                  isStroke: true)
                }
                .padding(.bottom)
                
                NavigationLink {
                    LoginView(didCompleteLoginProcess: self.didCompleteLoginProcess)
                } label: {
                    CustomCapsule(text: "ログイン",
                                  imageSystemName: nil,
                                  foregroundColor: .black,
                                  textColor: .white,
                                  isStroke: false)
                }
                
                Spacer()
            }
        }
        .onAppear {
            isShowTutorialView = true
        }
        .fullScreenCover(isPresented: $isShowTutorialView) {
            TutorialView {
                isShowTutorialView = false
            }
        }
    }
}

#Preview {
    EntryView(didCompleteLoginProcess: {})
}

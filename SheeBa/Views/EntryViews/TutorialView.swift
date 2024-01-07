//
//  TutorialView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/18.
//

import SwiftUI

struct TutorialView: View {
    
    let didCompleteTutorialProcess: () -> ()
    @State private var selectedTab: Int = 1         // 選択されたページ
    let pages: [Int] = [1, 2, 3, 4]                 // ページ
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ForEach(pages, id: \.self) { page in
                    Tutorial(text: String.tutorialText(page: page),
                             lastPage: pages.count,
                             selectedTab: $selectedTab,
                             didAction: didCompleteTutorialProcess)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .animation(.easeInOut, value: selectedTab)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Spacer()
                        if selectedTab != pages.endIndex {
                            Button {
                                didCompleteTutorialProcess()
                            } label: {
                                Text("スキップ")
                            }
                        }
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct Tutorial: View {
    
    let text: String
    let lastPage: Int
    @Binding var selectedTab: Int
    let didAction: () -> ()

    var body: some View {
        VStack {
            Spacer()
            
//            Image(systemName: "iphone")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 180, height: 180)
            
            Spacer()
            
            Text(text)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .font(.title2)
                .bold()
                .frame(height: 100)
            
            Spacer()
            
            Button {
                if selectedTab != lastPage {
                    selectedTab += 1
                } else {
                    didAction()
                }
            } label: {
                CustomCapsule(text: selectedTab != lastPage ? "次へ" : "始める", imageSystemName: nil, foregroundColor: .black, textColor: .white, isStroke: false)
            }
            
            Spacer()
        }
    }
}

#Preview {
    TutorialView(didCompleteTutorialProcess: {})
}

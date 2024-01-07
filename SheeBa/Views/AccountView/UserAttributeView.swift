//
//  UserAttribute.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2024/01/03.
//

import SwiftUI
import Charts

struct UserAttributeView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var tab: Tab = .age
    @State private var allUsers = [ChatUser]()          // 全ユーザー
    @State private var items: [String] = ages           // 項目種類
    @State private var allUserItems: [String] = []      // 取得した項目
    
    enum Tab {
        case age
        case address
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                CustomTabBar(tab: $tab, buttonTab: .age)
                CustomTabBar(tab: $tab, buttonTab: .address)
            }
            
//            Chart {
//                ForEach(items, id: \.self) { item in
//            if #available(iOS 17.0, *) {
//                Chart(items, id: \.self) { item in
//                    SectorMark(
//                        angle: .value("number", countItem(item))
//                    )
//                    .foregroundStyle(by: .value("item", item))
//                }
//                .padding(30)
//            }
            Chart {
                ForEach(items, id: \.self) { item in
                    BarMark(
                        x: .value("item", item),
                        y: .value("number", countItem(item))
                    )
                }
            }
            .padding(30)
//                }
//            }
        }
        .navigationTitle("ユーザー属性")
        .navigationBarTitleDisplayMode(.inline)
        .asBackButton()
        .onAppear {
            fetchAllUsers()
        }
        .onChange(of: tab) { value in
            switch value {
            case .age:
                self.items = ages
                addAllUserItems()
            case .address:
                self.items = addresses
                addAllUserItems()
            }
        }
    }
    
    // MARK: - CustomTabBar
    struct CustomTabBar: View {
        @Binding var tab: UserAttributeView.Tab
        let buttonTab: UserAttributeView.Tab
        
        var tabText: String {
            switch buttonTab {
            case .age:
                "年齢"
            case .address:
                "地域"
            }
        }
        
        // 各種サイズ
        let frameWidthHeight: CGFloat = 30
        let rectangleFrameHeight: CGFloat = 2
        
        var body: some View {
            VStack {
                Button {
                    tab = buttonTab
                } label: {
                    HStack {
                        Spacer()
                        Text(tabText)
                            .font(.title3)
                            .foregroundStyle(.black)
                        Spacer()
                    }
                }
                Rectangle()
                    .foregroundColor(tab == buttonTab ? .black : .white)
                    .frame(height: rectangleFrameHeight)
            }
        }
    }
    
    // MARK: - 全ユーザーを取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchAllUsers() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
            if error != nil {
                vm.handleNetworkError(error: error, errorMessage: "全ユーザーの取得に失敗しました。")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                
                // 追加するユーザーが自分以外の場合のみ、追加する。
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.allUsers.append(.init(data: data))
                }
            })
                addAllUserItems()
        }
    }
    
    // MARK: - 全ユーザーから取得した項目をひとまとめにする
    /// - Parameters: なし
    /// - Returns: なし
    private func addAllUserItems() {
        allUserItems.removeAll()
        
        for user in allUsers {
            switch tab {
            case .age:
                self.allUserItems.append(user.age)
            case .address:

                self.allUserItems.append(user.address)
            }
        }
    }
    
    // MARK: - 一つの項目の人数
    /// - Parameters:
    ///   - result: 調べる項目の人数
    /// - Returns: なし
    private func countItem(_ item: String) -> Int {
        var count = 0
        for allUserItem in allUserItems {
            if allUserItem == item {
                count += 1
            }
        }
        return count
    }
}

#Preview {
    UserAttributeView()
}

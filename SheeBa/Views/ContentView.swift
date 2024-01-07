//
//  ContentView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var isUserCurrentryLoggedOut = false                   // ユーザーのログインの有無
    
    init() {
        isUserCurrentryLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
//        if FirebaseManager.shared.auth.currentUser?.uid != nil {
//            vm.fetchCurrentUser()
//            vm.fetchRecentMessages()
//        }
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                HomeView(isUserCurrentryLoggedOut: $isUserCurrentryLoggedOut)
                    .tabItem {
                        VStack {
                            Image(systemName: "house")
                        }
                    }
                    .tag(1)
                CameraView(isUserCurrentryLoggedOut: $isUserCurrentryLoggedOut)
                    .tabItem {
                        VStack {
                            Image(systemName: "camera")
                        }
                    }
                    .tag(2)
                AccountView(isUserCurrentryLoggedOut: $isUserCurrentryLoggedOut)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.fill")
                        }
                    }
                    .tag(3)
            }
        }
        .tint(.black)
    }
}

#Preview {
    ContentView()
}

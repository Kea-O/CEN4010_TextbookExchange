//
//  ContentView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    private enum Tab: Hashable {
        case feed
        case myPosts
    }
    
    @StateObject private var between = PostBetweenView()
    @State private var currentUser = User.demo
    @State private var selectedTab: Tab = .feed
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FeedView()
            }
            .tabItem {
                Label("Feed", systemImage: "list.bullet.rectangle")
            }
            .tag(Tab.feed)
            .environmentObject(between)
            
            NavigationStack {
                UserPostView(user: currentUser)
            }
            .tabItem {
                Label("My Posts", systemImage: "person.crop.square")
            }
            .tag(Tab.myPosts)
            .environmentObject(between)
        }
    }
}

#Preview {
    ContentView()
}

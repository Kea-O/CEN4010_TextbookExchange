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
        case messages
    }
    
    @StateObject private var between = PostBetweenView()
    @StateObject private var messageBetween = MessageBetweenView()
    @State private var currentUser = User.demo
    @State private var selectedTab: Tab = .feed
    
    init() {
        // Enable mock data mode when Firebase permissions aren't set up
        // Set to false when Firebase is ready
        let useMockData = true // Change to false when Firebase rules are deployed
        _between = StateObject(wrappedValue: {
            let view = PostBetweenView()
            view.useMockData = useMockData
            return view
        }())
    }
    
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
            .environmentObject(messageBetween)
            
            NavigationStack {
                UserPostView(user: currentUser)
            }
            .tabItem {
                Label("My Posts", systemImage: "person.crop.square")
            }
            .tag(Tab.myPosts)
            .environmentObject(between)
            
            NavigationStack {
                ConversationListView(currentUser: currentUser)
            }
            .tabItem {
                Label("Messages", systemImage: "message")
            }
            .tag(Tab.messages)
            .environmentObject(messageBetween)
        }
        .onAppear {
            messageBetween.useMockData = true
        }
    }
}

#Preview {
    ContentView()
}

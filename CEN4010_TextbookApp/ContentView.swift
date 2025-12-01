//
//  ContentView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/4/25.
//

import SwiftUI

enum AppTab: Hashable {
    case feed
    case myPosts
    case messages
}

struct ContentView: View {
    
    // Create variables for the @Observable or @MainActor views that deal with managing the functions that connect the app with Firebase.
    @StateObject private var postBetween = PostBetweenView()
    @StateObject private var messageBetween = MessageBetweenView()
    @State private var authManager = AuthManager()
    
    // A variable for seeing which tab was selected in the navigation bar:
    @State private var selectedTab: AppTab? = .feed
    
    // Have Login view become the main view, and the first view the user is sent to:
    var body: some View {
        // Check if the user has been authenticated. If not, send them to the login screen. After they're authenticated, we'll set the currentUsers as the logged in user.
        if authManager.isAuthenticated, let currentUser = authManager.appUser {
            mainTabView(currentUser: currentUser)
        } else {
            LoginView()
                .environment(authManager)
        }
    }
    
    @ViewBuilder
    private func mainTabView(currentUser: AppUser) -> some View {
        TabView(selection: Binding(
            get: { selectedTab ?? .feed },
            set: { selectedTab = $0 }
        )) {
            NavigationStack {
                FeedView(user: currentUser, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Feed", systemImage: "list.bullet.rectangle")
            }
            .tag(AppTab.feed)
            .environmentObject(postBetween)
            .environmentObject(messageBetween)
            .environment(authManager)
            
            NavigationStack {
                UserPostView(user: currentUser)
            }
            .tabItem {
                Label("My Posts", systemImage: "person.crop.square")
            }
            .tag(AppTab.myPosts)
            .environmentObject(postBetween)
            .environment(authManager)
            
            NavigationStack {
                ConversationListView(currentUser: currentUser)
            }
            .tabItem {
                Label("Messages", systemImage: "message")
            }
            .tag(AppTab.messages)
            .environmentObject(messageBetween)
        }
        .onAppear {
            if let userId = currentUser.id {
                messageBetween.startIncomingMessageListener(for: userId)
            }
            NotificationManager.shared.requestAuthorizationIfNeeded()
        }
    }
}

#Preview {
    ContentView()
}

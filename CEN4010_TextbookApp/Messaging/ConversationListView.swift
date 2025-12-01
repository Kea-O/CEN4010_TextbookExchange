//
//  ConversationListView.swift
//  CEN4010_TextbookApp
//
//  View showing list of all conversations
//

import SwiftUI

struct ConversationListView: View {
    @EnvironmentObject var messageBetween: MessageBetweenView
    let currentUser: AppUser
    @State private var users: [AppUser] = []
    
    var body: some View {
        List {
            ForEach(conversations) { conversation in
                NavigationLink {
                    ChatView(
                        conversation: conversation,
                        currentUser: currentUser,
                        otherUser: getUser(for: conversation)
                    )
                    .environmentObject(messageBetween)
                } label: {
                    ConversationRow(
                        conversation: conversation,
                        currentUser: currentUser,
                        otherUser: getUser(for: conversation)
                    )
                }
            }
        }
        .navigationTitle("Messages")
        .task {
            await messageBetween.loadConversations(userId: currentUser.id ?? "")
        }
        .onAppear {
            // Refresh conversations when view appears (e.g., after creating a new conversation)
            Task {
                await messageBetween.loadConversations(userId: currentUser.id ?? "")
            }
        }
        .refreshable {
            await messageBetween.loadConversations(userId: currentUser.id ?? "")
        }
    }
    
    private var conversations: [Conversation] {
        messageBetween.conversations
    }
    
    private func getUser(for conversation: Conversation) -> AppUser? {
        let otherId = conversation.otherParticipantId(currentUserId: currentUser.id ?? "")
        return messageBetween.users[otherId]
    }
}

private struct ConversationRow: View {
    let conversation: Conversation
    let currentUser: AppUser
    let otherUser: AppUser?
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(initials)
                        .font(.headline)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(otherUser?.name ?? "Unknown User")
                    .font(.headline)
                
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("No messages yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            if let timestamp = conversation.lastMessageTimestamp {
                Text(timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var initials: String {
        let name = otherUser?.name ?? "U"
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

#Preview {
    NavigationStack {
        ConversationListView(currentUser: .demo)
            .environmentObject(MessageBetweenView())
    }
}


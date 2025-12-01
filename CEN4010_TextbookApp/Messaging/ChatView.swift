//
//  ChatView.swift
//  CEN4010_TextbookApp
//
//  Individual chat/conversation view
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var messageBetween: MessageBetweenView
    let conversation: Conversation
    let currentUser: User
    let otherUser: User?
    
    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool
    
    private var messages: [Message] {
        messageBetween.messages[conversation.id ?? ""] ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == (currentUser.demoID ?? currentUser.id)
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input
            MessageInputView(
                text: $messageText,
                onSend: {
                    sendMessage()
                }
            )
            .focused($isInputFocused)
        }
        .navigationTitle(otherUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await messageBetween.loadMessages(conversationId: conversation.id ?? "")
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let currentUserId = currentUser.demoID ?? currentUser.id ?? ""
        let otherUserId = otherUser?.mockUserID ?? conversation.otherParticipantId(currentUserId: currentUserId)
        
        Task {
            await messageBetween.sendMessage(
                conversationId: conversation.id ?? "",
                senderId: currentUserId,
                receiverId: otherUserId,
                text: messageText
            )
            messageText = ""
        }
    }
}

private struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                            ? Color.blue
                            : Color(.secondarySystemBackground)
                    )
                    .foregroundColor(
                        isFromCurrentUser
                            ? .white
                            : .primary
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isFromCurrentUser ? .trailing : .leading)
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

private struct MessageInputView: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(text.isEmpty ? .gray : .blue)
            }
            .disabled(text.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    let conversation = Conversation(
        id: "alex-johnson-001_demo-user-001",
        participant1Id: "alex-johnson-001",
        participant2Id: "demo-user-001",
        lastMessage: "Test message",
        lastMessageTimestamp: Date(),
        postId: nil
    )
    
    return NavigationStack {
        ChatView(
            conversation: conversation,
            currentUser: .demo,
            otherUser: .alex
        )
        .environmentObject({
            let view = MessageBetweenView()
            view.useMockData = true
            return view
        }())
    }
}


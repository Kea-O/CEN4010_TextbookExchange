//
//  MessageBetweenView.swift
//  CEN4010_TextbookApp
//
//  View model for managing messages and conversations
//

import Foundation

@MainActor
final class MessageBetweenView: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []
    @Published private(set) var messages: [String: [Message]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let manager = MessageManager()
    var useMockData: Bool = false
    
    // Load all conversations for a user
    func loadConversations(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        if useMockData {
            conversations = Conversation.mockConversations.filter { $0.involves(userId: userId) }
            errorMessage = nil
        } else {
            do {
                conversations = try await manager.fetchConversations(userId: userId)
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // Load messages for a specific conversation
    func loadMessages(conversationId: String) async {
        if useMockData {
            messages[conversationId] = Message.mockMessages.filter { $0.conversationId == conversationId }
                .sorted { $0.timestamp < $1.timestamp }
        } else {
            do {
                let fetchedMessages = try await manager.fetchMessages(conversationId: conversationId)
                messages[conversationId] = fetchedMessages
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // Send a message
    func sendMessage(
        conversationId: String,
        senderId: String,
        receiverId: String,
        text: String
    ) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        if useMockData {
            // Add to mock messages
            let newMessage = Message(
                id: "mock-msg-\(UUID().uuidString)",
                conversationId: conversationId,
                senderId: senderId,
                receiverId: receiverId,
                text: text,
                timestamp: Date(),
                isRead: false
            )
            messages[conversationId, default: []].append(newMessage)
            
            // Update conversation's last message
            if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
                conversations[index].lastMessage = text
                conversations[index].lastMessageTimestamp = Date()
                // Sort conversations by last message timestamp
                conversations.sort { conv1, conv2 in
                    let time1 = conv1.lastMessageTimestamp ?? Date.distantPast
                    let time2 = conv2.lastMessageTimestamp ?? Date.distantPast
                    return time1 > time2
                }
            } else {
                // If conversation not in list, reload conversations
                await loadConversations(userId: senderId)
            }
        } else {
            do {
                try await manager.sendMessage(
                    conversationId: conversationId,
                    senderId: senderId,
                    receiverId: receiverId,
                    text: text
                )
                await loadMessages(conversationId: conversationId)
                await loadConversations(userId: senderId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // Get or create conversation
    func getOrCreateConversation(
        participant1Id: String,
        participant2Id: String,
        postId: String?
    ) async -> Conversation? {
        guard !participant1Id.isEmpty && !participant2Id.isEmpty else {
            errorMessage = "Invalid user IDs"
            return nil
        }
        
        if useMockData {
            // Find existing or create new mock conversation
            let sortedIds = [participant1Id, participant2Id].sorted()
            let conversationId = "\(sortedIds[0])_\(sortedIds[1])"
            
            // Check existing conversations first
            if let existing = conversations.first(where: { $0.id == conversationId }) {
                return existing
            }
            
            // Check mock conversations
            if let existing = Conversation.mockConversations.first(where: { $0.id == conversationId }) {
                // Add to conversations array if not already there
                if !conversations.contains(where: { $0.id == conversationId }) {
                    conversations.append(existing)
                }
                return existing
            }
            
            // Create new conversation
            let newConv = Conversation(
                id: conversationId,
                participant1Id: sortedIds[0],
                participant2Id: sortedIds[1],
                lastMessage: nil,
                lastMessageTimestamp: nil,
                postId: postId
            )
            
            // Add to conversations array
            conversations.append(newConv)
            return newConv
        } else {
            do {
                return try await manager.getOrCreateConversation(
                    participant1Id: participant1Id,
                    participant2Id: participant2Id,
                    postId: postId
                )
            } catch {
                errorMessage = error.localizedDescription
                return nil
            }
        }
    }
}


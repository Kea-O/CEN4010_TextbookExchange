//
//  MessageManager.swift
//  CEN4010_TextbookApp
//
//  Manager for handling messages and conversations
//

import Foundation
import FirebaseFirestore

class MessageManager {
    private let db = Firestore.firestore()
    
    @Published private(set) var users: [String: AppUser] = [:]

    func fetchUser(userId: String) async {
        guard users[userId] == nil else { return }
        
        do {
            if let user = try await AuthManager().fetchUserById(userId: userId) {
                users[userId] = user
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
    
    // Get or create a conversation between two users
    func getOrCreateConversation(
        participant1Id: String,
        participant2Id: String,
        postId: String?
    ) async throws -> Conversation {
        // Sort IDs to ensure consistent conversation ID
        let sortedIds = [participant1Id, participant2Id].sorted()
        let conversationId = "\(sortedIds[0])_\(sortedIds[1])"
        
        let conversationRef = db.collection("Conversations").document(conversationId)
        
        // Try to get existing conversation
        if let document = try? await conversationRef.getDocument(),
           document.exists,
           let conversation = try? document.data(as: Conversation.self) {
            return conversation
        }
        
        // Create new conversation
        let newConversation = Conversation(
            id: conversationId,
            participant1Id: sortedIds[0],
            participant2Id: sortedIds[1],
            lastMessage: nil,
            lastMessageTimestamp: nil,
            postId: postId
        )
        
        try conversationRef.setData(from: newConversation)
        return newConversation
    }
    
    // Send a message
    func sendMessage(
        conversationId: String,
        senderId: String,
        receiverId: String,
        text: String
    ) async throws {
        let message = Message(
            id: nil,
            conversationId: conversationId,
            senderId: senderId,
            receiverId: receiverId,
            text: text,
            timestamp: Date(),
            isRead: false
        )
        
        // Add message to Messages collection
        try await db.collection("Messages").addDocument(from: message)
        
        // Update conversation's last message
        let conversationRef = db.collection("Conversations").document(conversationId)
        try await conversationRef.updateData([
            "lastMessage": text,
            "lastMessageTimestamp": Timestamp(date: Date())
        ])
    }
    
    // Fetch messages for a conversation
    func fetchMessages(conversationId: String) async throws -> [Message] {
        let snapshot = try await db.collection("Messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Message.self)
        }
    }
    
    // Fetch all conversations for a user
    func fetchConversations(userId: String) async throws -> [Conversation] {
        let snapshot = try await db.collection("Conversations")
            .whereField("participant1Id", isEqualTo: userId)
            .getDocuments()
        
        let snapshot2 = try await db.collection("Conversations")
            .whereField("participant2Id", isEqualTo: userId)
            .getDocuments()
        
        var conversations: [Conversation] = []
        conversations.append(contentsOf: snapshot.documents.compactMap { try? $0.data(as: Conversation.self) })
        conversations.append(contentsOf: snapshot2.documents.compactMap { try? $0.data(as: Conversation.self) })
        
        // Sort by last message timestamp
        return conversations.sorted { conv1, conv2 in
            let time1 = conv1.lastMessageTimestamp ?? Date.distantPast
            let time2 = conv2.lastMessageTimestamp ?? Date.distantPast
            return time1 > time2
        }
    }
    
    // Mark messages as read
    func markMessagesAsRead(conversationId: String, userId: String) async throws {
        let snapshot = try await db.collection("Messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .whereField("receiverId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.updateData(["isRead": true], forDocument: doc.reference)
        }
        try await batch.commit()
    }
}


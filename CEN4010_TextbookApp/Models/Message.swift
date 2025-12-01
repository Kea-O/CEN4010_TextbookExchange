//
//  Message.swift
//  CEN4010_TextbookApp
//
//  Created for messaging feature
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var conversationId: String
    var senderId: String
    var receiverId: String
    var text: String
    var timestamp: Date = Date()
    var isRead: Bool = false
}

// Conversation model to group messages between two users
struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var participant1Id: String
    var participant2Id: String
    var lastMessage: String?
    var lastMessageTimestamp: Date?
    var postId: String? // Optional: link to the post this conversation is about
    
    // Helper to get the other participant's ID
    func otherParticipantId(currentUserId: String) -> String {
        return participant1Id == currentUserId ? participant2Id : participant1Id
    }
    
    // Helper to check if conversation involves a specific user
    func involves(userId: String) -> Bool {
        return participant1Id == userId || participant2Id == userId
    }
}


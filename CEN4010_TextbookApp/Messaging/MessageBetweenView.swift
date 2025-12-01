//
//  MessageBetweenView.swift
//  CEN4010_TextbookApp
//
//  View model for managing messages and conversations
//

import Foundation
import FirebaseFirestore

@MainActor
final class MessageBetweenView: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []
    @Published private(set) var messages: [String: [Message]] = [:]
    @Published private(set) var users: [String: AppUser] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let manager = MessageManager()
    private var incomingListener: ListenerRegistration?

    private var conversationListeners: [String: ListenerRegistration] = [:]
    
    // Load all conversations for a user
    func loadConversations(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            conversations = try await manager.fetchConversations(userId: userId)
            
            // Fetch all participant users
            for conversation in conversations {
                let otherUserId = conversation.otherParticipantId(currentUserId: userId)
                await fetchUser(userId: otherUserId)
            }
            
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
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
    
    // Load messages for a specific conversation
    func loadMessages(conversationId: String) async {
        do {
            let fetchedMessages = try await manager.fetchMessages(conversationId: conversationId)
            messages[conversationId] = fetchedMessages
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Send a message
    func sendMessage(
        conversationId: String,
        senderId: String,
        receiverId: String,
        text: String,
        senderName: String? = nil,
        bookTitle: String? = nil
    ) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        do {
            try await manager.sendMessage(
                conversationId: conversationId,
                senderId: senderId,
                receiverId: receiverId,
                text: text
            )
            await loadMessages(conversationId: conversationId)
            await loadConversations(userId: senderId)
            // Notification removed here – this code runs on the sender’s device
        } catch {
            errorMessage = error.localizedDescription
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
    
    func startIncomingMessageListener(for userId: String) {
        // Remove previous listener if any
        incomingListener?.remove()
        
        let db = Firestore.firestore()
        
        incomingListener = db.collection("Messages")
            .whereField("receiverId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Incoming message listener error: \(error)")
                    return
                }
                
                guard let changes = snapshot?.documentChanges else { return }
                
                for change in changes where change.type == .added {
                    if let message = try? change.document.data(as: Message.self) {
                        Task { @MainActor in
                            await self.handleIncoming(message: message)
                        }
                    }
                }
            }
    }
    
    func startConversationListener(conversationId: String) {
        guard !conversationId.isEmpty else { return }

        // Remove any existing listener for this conversation
        conversationListeners[conversationId]?.remove()

        let db = Firestore.firestore()

        let listener = db.collection("Messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Conversation listener error for \(conversationId): \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let fetchedMessages: [Message] = documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                }

                Task { @MainActor in
                    self.messages[conversationId] = fetchedMessages
                }
            }

        conversationListeners[conversationId] = listener
    }

    func stopConversationListener(conversationId: String) {
        conversationListeners[conversationId]?.remove()
        conversationListeners[conversationId] = nil
    }
    
    private func handleIncoming(message: Message) async {
        // Update local messages dictionary (optional but nice)
        var convMessages = messages[message.conversationId] ?? []
        if !convMessages.contains(where: { $0.id == message.id }) {
            convMessages.append(message)
            messages[message.conversationId] = convMessages
        }
        
        // Resolve sender name
        let senderName: String
        if let cached = users[message.senderId] {
            senderName = cached.name
        } else if let user = try? await AuthManager().fetchUserById(userId: message.senderId) {
            users[message.senderId] = user
            senderName = user.name
        } else {
            senderName = "Someone"
        }
        
        let bookTitle = "your textbook" // or look up via conversation.postId
        
        NotificationManager.shared.notifyNewMessage(from: senderName, about: bookTitle)
    }
    
    deinit {
        incomingListener?.remove()
        for (_, listener) in conversationListeners {
            listener.remove()
        }
    }
}


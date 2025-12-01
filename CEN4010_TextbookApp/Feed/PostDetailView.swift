//
//  PostDetailView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var messageBetween: MessageBetweenView
    @State private var currentUser = User.demo
    @State private var showChat = false
    @State private var conversation: Conversation?
    
    private var currencyFormatter: String {
        post.price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
    
    // Get seller info from post.user_id
    private var seller: User? {
        User.mockUsers.first { user in
            (user.demoID ?? user.id) == post.user_id
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                metadataSection
                meetupSection
                
                // Message seller button
                if let seller = seller, seller.demoID != currentUser.demoID {
                    Button {
                        Task {
                            await openChat(with: seller)
                        }
                    } label: {
                        Label("Message Seller", systemImage: "message.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showChat) {
            if let conversation = conversation, let seller = seller {
                NavigationStack {
                    ChatView(
                        conversation: conversation,
                        currentUser: currentUser,
                        otherUser: seller
                    )
                    .environmentObject(messageBetween)
                }
            } else {
                // Show loading state while conversation is being created
                NavigationStack {
                    ProgressView("Starting conversation...")
                        .navigationTitle("Chat")
                }
            }
        }
        .onAppear {
            messageBetween.useMockData = true
            // Reset conversation when viewing a different post
            conversation = nil
        }
        .onChange(of: post.id) { _, _ in
            // Reset conversation when post changes
            conversation = nil
            showChat = false
        }
    }
    
    private func openChat(with seller: User) async {
        let currentUserId = currentUser.demoID ?? currentUser.id ?? ""
        let sellerId = seller.demoID ?? seller.id ?? ""
        
        // Reset conversation state first
        conversation = nil
        
        // Create conversation first
        let newConversation = await messageBetween.getOrCreateConversation(
            participant1Id: currentUserId,
            participant2Id: sellerId,
            postId: post.id
        )
        
        // Only show sheet after conversation is created
        if let newConversation = newConversation {
            conversation = newConversation
            // Load messages for the new conversation
            await messageBetween.loadMessages(conversationId: newConversation.id ?? "")
            showChat = true
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.author)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(currencyFormatter)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.green)
            if let edition = post.edition, !edition.isEmpty {
                Text("Edition: \(edition)")
            }
            if let isbn = post.isbn, !isbn.isEmpty {
                Text("ISBN: \(isbn)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Subject: \(post.subject)", systemImage: "books.vertical")
            Label("Condition: \(post.condition)", systemImage: "shippingbox.fill")
            Label("Listed: \(post.timestamp.formatted(date: .abbreviated, time: .shortened))", systemImage: "clock.fill")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var meetupSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pickup Details")
                .font(.headline)
            Text("Locations")
                .font(.subheadline.weight(.semibold))
            Text(post.locations)
            Divider()
            Text("Times")
                .font(.subheadline.weight(.semibold))
            Text(post.times)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let sample = Post(
        user_id: "demo-user-001",
        title: "Calculus: Early Transcendentals",
        author: "Stewart",
        edition: "9th",
        isbn: "978-1-337-55828-9",
        subject: Subject.MathematicsStatistics.rawValue,
        price: 85.0,
        locations: "Library or Engineering Atrium",
        times: "Weekdays after 3 PM",
        condition: Condition.Good.rawValue,
        image_url: "https://example.com"
    )
    PostDetailView(post: sample)
}
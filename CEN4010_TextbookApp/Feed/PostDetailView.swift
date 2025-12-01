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
    @Environment(AuthManager.self) var authManager
    @Binding var selectedTab: AppTab?
    
    @State private var seller: AppUser?
    @State private var isLoadingSeller = false
    
    @State private var sellerRating: UserRating?
    @State private var isLoadingRating = false
    private let reviewManager = ReviewManager()
    
    private var currencyFormatter: String {
        post.price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
    
    private var currentUser: AppUser? {
        authManager.appUser
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                imageSection
                metadataSection
                meetupSection
                
                // Message seller button
                if let seller = seller, let currentUser = currentUser, seller.id != currentUser.id {
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
                    .disabled(isLoadingSeller)
                } else if isLoadingSeller {
                    ProgressView("Loading seller info...")
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await loadSeller()
                await loadSellerRating()
            }
        }
    }
    
    private func loadSeller() async {
        guard seller == nil, !isLoadingSeller else { return }
        isLoadingSeller = true
        defer { isLoadingSeller = false }
        
        // Try to fetch seller from Firestore
        let sellerId = post.user_id
        if !sellerId.isEmpty {
            do {
                seller = try await authManager.fetchUserById(userId: sellerId)
            } catch {
                print("Error fetching seller: \(error)")
                // Fallback to mock users if Firestore fetch fails
                seller = AppUser.mockUsers.first { user in
                    (user.id ?? "") == sellerId
                }
            }
        }
    }
    
    private func loadSellerRating() async {
        guard let sellerId = seller?.id, !sellerId.isEmpty else { return }
        isLoadingRating = true
        defer { isLoadingRating = false }
        
        do {
            sellerRating = try await reviewManager.getUserRating(userId: sellerId)
        } catch {
            print("Error fetching seller rating: \(error)")
        }
    }
    
    private func openChat(with seller: AppUser) async {
        guard let currentUser = currentUser,
              let currentUserId = currentUser.id,
              let sellerId = seller.id else { return }
        
        // Create or get conversation
        let newConversation = await messageBetween.getOrCreateConversation(
            participant1Id: currentUserId,
            participant2Id: sellerId,
            postId: post.id
        )
        
        // Navigate to messages tab and refresh conversations
        if newConversation != nil {
            // Refresh conversations list
            await messageBetween.loadConversations(userId: currentUserId)
            // Switch to messages tab
            selectedTab = .messages
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.author)
                .font(.title3)
                .foregroundStyle(.secondary)
            if let rating = sellerRating {
                HStack(spacing: 4) {
                    Text(String(format: "%.1f ★", rating.averageRating))
                        .font(.subheadline.weight(.semibold))
                    Text("(\(rating.reviewCount) reviews)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(currencyFormatter)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.green)
            Text("Edition: \(post.edition)")
            Text("ISBN: \(post.isbn)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var imageSection: some View {
        Group {
            if let url = URL(string: post.image_url),
               !post.image_url.isEmpty {

                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                            ProgressView()
                        }
                        .frame(height: 250)

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)

                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Failed to load image")
                                    .font(.caption)
                            }
                        }
                        .frame(height: 250)

                    @unknown default:
                        EmptyView()
                    }
                }

            } else {
                // Fallback UI if no image provided
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("No Image Provided")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                .frame(height: 250)
            }
        }
        .padding(.bottom, 10)
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
}

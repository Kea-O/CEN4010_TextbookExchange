//
//  UserPostView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import SwiftUI

struct UserPostView: View {
    @EnvironmentObject var between: PostBetweenView
    let user: User
    
    @State private var postPendingDeletion: Post?
    @State private var showDeleteAlert = false
    @State private var showCreatePost = false
    
    private var userPosts: [Post] {
        // Use demoID for demo users, otherwise use the actual id
        let userId = user.demoID ?? user.id
        guard let userId = userId else { return [] }
        return between.posts.filter { $0.user_id == userId }
    }
    
    var body: some View {
        List {
            ForEach(userPosts) { post in
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.author)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(post.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.green)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        postPendingDeletion = post
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .overlay {
            if between.isLoading && userPosts.isEmpty {
                ProgressView()
            } else if userPosts.isEmpty {
                ContentUnavailableView("No posts yet", systemImage: "square.stack.3d.up.slash", description: Text("Create a post to see it here."))
            }
        }
        .navigationTitle("My Posts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreatePost = true
                } label: {
                    Label("Create Post", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView(user: user)
                .environmentObject(between)
        }
        .alert("Delete post?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                postPendingDeletion = nil
            }
            Button("Delete", role: .destructive) {
                deletePendingPost()
            }
        } message: {
            Text("This action removes the post permanently.")
        }
    }
    
    private func deletePendingPost() {
        guard let post = postPendingDeletion else { return }
        Task {
            await between.delete(post: post)
            postPendingDeletion = nil
        }
    }
}

#Preview {
    UserPostView(user: .demo)
        .environmentObject(PostBetweenView())
}

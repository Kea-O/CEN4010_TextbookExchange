//
//  PostListViewModel.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import Foundation

// We'll need an in-between view using the functions from the manager to add/delete posts and act as a buffer/loading screen for the views users are using.
@MainActor
final class PostBetweenView: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let manager = PostManager()
    
    // Set to true to use mock data instead of Firebase (useful when Firebase permissions aren't set up)
    var useMockData: Bool = false
    
    func loadPosts(force: Bool = false) async {
        if isLoading && !force { return }
        isLoading = true
        defer { isLoading = false }
        
        if useMockData {
            // Use mock data for development
            posts = Post.mockPosts.sorted { $0.timestamp > $1.timestamp }
            errorMessage = nil
        } else {
            do {
                posts = try await manager.fetchPost()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func refresh() async {
        await loadPosts(force: true)
    }
    
    func create(post: Post) async throws {
        do {
            try await manager.createPost(post: post)
            await loadPosts(force: true)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func delete(post: Post) async {
        guard let id = post.id else {
            errorMessage = "Unable to delete post without an id."
            return
        }
        
        do {
            try await manager.deletePost(id: id)
            posts.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


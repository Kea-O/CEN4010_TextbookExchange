//
//  PostListViewModel.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import Foundation
// Import UIKit for images:
import UIKit

// We'll need an in-between view using the functions from the manager to add/delete posts and act as a buffer/loading screen for the views users are using.
@MainActor
final class PostBetweenView: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let manager = PostManager()
    
    func loadPosts(force: Bool = false) async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let newPosts = try await manager.fetchPost()
            
            // Change only if new data was introduced or old data deleted.
            if posts != newPosts {
                posts = newPosts
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func refresh() async {
        await loadPosts(force: true)
    }
    
    // Function that mirrors the save image function from PostManager:
    func saveImage(data: Data, ID: String) async throws -> String {
        do {
            let url = try await manager.uploadImage(imageData: data, postID: ID)
            return url
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
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

